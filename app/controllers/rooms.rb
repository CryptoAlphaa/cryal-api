# frozen_string_literal: true

require 'roda'
require_relative './app'

module Cryal
  # Web controller for Credence API
    class Api < Roda
        include Cryal
        route('rooms') do |routing|
            # make three routing, get all rooms associated, create room, join room
            # GET /api/v1/rooms?room_id=1
            routing.is do
                routing.get do
                    room_id = routing.params['room_id']
                    if room_id.nil?
                        rooms = Cryal::AccountService::Room::FetchAll.call(requestor: @auth_account)
                    else
                        room = Cryal::AccountService::Room::FetchOne.call(@auth_account, room_id)
                    end
                    response.status = 200
                    { message: 'Success', data: rooms }.to_json
                rescue Cryal::AccountService::Room::FetchAll::ForbiddenError => e
                    routing.halt 403, { message: 'Forbidden' }.to_json
                rescue Cryal::AccountService::Room::FetchOne::NotFoundError => e
                    routing.halt 404, { message: 'Not Found'}.to_json
                end
            end

            # POST /api/v1/rooms/createroom
            routing.on 'createroom' do
                routing.post do
                    json = JSON.parse(routing.body.read)
                    output = Cryal::AccountService::Room::Create.call(routing, json, @auth_account.account_id)
                    response.status = 201
                    { message: 'Room created', data: output }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, json, e)
                end
            end

            # POST /api/v1/rooms/joinroom
            routing.on 'joinroom' do
                routing.post do
                    join_request = JSON.parse(routing.body.read)
                    output = Cryal::AccountService::Room::Join.call(requestor_id: @auth_account, request: join_request)
                    response.status = 201
                    { message: 'Room Join Successfully', data: output }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, json, e)
                end
            end

            routing.on String do |room_id|
                # p "routing inspect: #{routing.inspect}"
                routing.on 'plans' do
                    # GET /api/v1/rooms/room_id/plans?plan_name="some_plan_name"
                    routing.get do
                        plan_name = routing.params['plan_name']
                        plans = Cryal::AccountService::Plans::Fetch.call(@auth_account, room_id, plan_name)
                        response.status = 200
                        { message: 'Success', data: plans }.to_json
                        rescue Cryal::AccountService::Plans::Fetch::ForbiddenError => e
                            routing.halt 403, { message: e.message }.to_json
                        rescue Cryal::AccountService::Plans::Fetch::PlansNotFoundError => e
                            routing.halt 404, { message: e.message }.to_json
                        rescue StandardError => e
                            routing.halt 500, { message: 'API Server Error' }.to_json
                    end


                    # POST /api/v1/rooms/room_id/plans
                    routing.post do
                        new_plan = JSON.parse(routing.body.read)
                        output = Cryal::AccountService::Plans::Create.call(@auth_account, room_id, new_plan)
                        response.status = 201
                        { message: 'Plan saved', data: output }.to_json
                        rescue Cryal::AccountService::Plans::Create::ForbiddenError => e
                            routing.halt 403, { message: e.message }.to_json
                        rescue Cryal::AccountService::Plans::Create::NotFoundError => e
                            routing.halt 404, { message: e.message }.to_json
                        rescue StandardError => e
                            log_and_handle_error(routing, new_plan, e)
                    end
                end    
            end
        end
    end
end
