# frozen_string_literal: true

require 'roda'
require_relative './app'

# routing.on 'plans' do # rubocop:disable Metrics/BlockLength
#     # POST /api/v1/accounts/[account_id]/plans/create_plan DONEE
#     routing.on 'create_plan' do
#       routing.post do
#         # user_create_plan(routing, account_id)
#         json = JSON.parse(routing.body.read)
#         output = Cryal::AccountService::Plans::Create.call(routing, json, account_id)
#         response.status = 201
#         { message: 'Plan saved', data: output }.to_json
#       rescue StandardError => e
#         log_and_handle_error(routing, json, e)
#       end
#     end

#     # GET /api/v1/accounts/[account_id]/plans/fetch DONEE
#     routing.on 'fetch' do
#       routing.get do
#         # user_fetch_plans(routing, account_id)
#         output = Cryal::AccountService::Plans::FetchOne.call(routing, account_id)
#         response.status = 200
#         output.to_json
#       end
#     end


# # api/v1/accounts/[account_id]/plans/[plan_id]
# routing.on String do |plan_id|
#     routing.on 'waypoints' do
#       # POST /api/v1/accounts/[account_id]/plans/[plan_id]/waypoints DONEE
#       routing.post do
#         # user_create_waypoint(routing, account_id, plan_id)
#         json = JSON.parse(routing.body.read)
#         output = Cryal::AccountService::Waypoint::Create.call(routing, json, account_id, plan_id)
#         response.status = 201
#         { message: 'Waypoint saved', data: output }.to_json
#       rescue StandardError => e
#         log_and_handle_error(routing, json, e)
#       end

#       # GET /api/v1/accounts/[account_id]/plans/[plan_id]/waypoints DONE
#       routing.get do
#         # user_fetch_waypoints(routing, account_id, plan_id)
#         output = Cryal::AccountService::Waypoint::FetchOne.call(routing, account_id, plan_id)
#         response.status = 200
#         output.to_json
#       end

module Cryal
    # Web controller for Credence API
    class Api < Roda
        include Cryal
            route('plans') do |routing|
                # make two routing, create plan, fetch plan
                # POST /api/v1/plans/create_plan
                routing.on 'create_plan' do
                    routing.post do
                        account = Account.first(username: @auth_account['username'])
                        json = JSON.parse(routing.body.read)
                        output = Cryal::AccountService::Plans::Create.call(routing, json, account.account_id)
                        response.status = 201
                        { message: 'Plan saved', data: output }.to_json
                    rescue StandardError => e
                        log_and_handle_error(routing, json, e)
                    end
                end

                # GET /api/v1/plans/fetch
                routing.on 'fetch' do
                    routing.get do
                        account = Account.first(username: @auth_account['username'])
                        output = Cryal::AccountService::Plans::FetchOne.call(routing, account.account_id)
                        response.status = 200
                        output.to_json
                    end
                end

                routing.on String do |plan_id|
                    routing.on 'waypoints' do
                        account = Account.first(username: @auth_account['username'])
                        # POST /api/v1/plans/[plan_id]/waypoints
                        routing.post do
                            json = JSON.parse(routing.body.read)
                            output = Cryal::AccountService::Waypoint::Create.call(routing, json, account.account_id, plan_id)
                            response.status = 201
                            { message: 'Waypoint saved', data: output }.to_json
                        rescue StandardError => e
                            log_and_handle_error(routing, json, e)
                        end

                        # GET /api/v1/plans/[plan_id]/waypoints?waypoint_number=1
                        routing.get do
                            if routing.params['waypoint_number']
                                output = Cryal::AccountService::Waypoint::FetchOne.call(routing, account.account_id, plan_id)
                            else
                                output = Cryal::AccountService::Waypoint::FetchAll.call(routing, account.account_id, plan_id)
                            end
                            response.status = 200
                            output.to_json
                        end
                    end
                end
            end
    end
end