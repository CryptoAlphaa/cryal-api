# frozen_string_literal: true

require 'sequel'
require 'roda'
require 'json'

# Cryal Module
module Cryal
  # Class for designing the API
  class Api < Roda # rubocop:disable Metrics/ClassLength
    plugin :environments
    plugin :halt
    plugin :json

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'Welcome to Cryal APIs' }.to_json
      end

      routing.on 'api/v1' do # rubocop:disable Metrics/BlockLength
        routing.on 'auth' do
          routing.on 'authentication' do
            routing.post do
              json = JSON.parse(routing.body.read)
              authenticate = Cryal::Authenticate.call(routing, json)
              response.status = 200
              authenticate.to_json
            end
          end
        end

        routing.on 'accounts' do # rubocop:disable Metrics/BlockLength
          routing.on String do |account_id| # rubocop:disable Metrics/BlockLength
            routing.is do
              # GET /api/v1/accounts/[account_id] DONE
              routing.get do
                output = Cryal::AccountService::Account::FetchOne.call(routing, account_id)
                response.status = 200
                output.to_json
              end
            end

            routing.on 'locations' do
              # GET /api/v1/accounts/[account_id]/locations DONEE
              routing.get do
                output = Cryal::AccountService::Location::FetchAll.call(routing, account_id)
                response.status = 200
                output.to_json
                # user_fetch_locations(routing, account_id)
              end

              # POST /api/v1/accounts/[account_id]/locations DONEE
              routing.post do
                json = JSON.parse(routing.body.read)
                output = Cryal::AccountService::Location::Create.call(routing, json, account_id)

                response.status = 201
                { message: 'Location saved', data: output }.to_json
              rescue StandardError => e
                log_and_handle_error(routing, json, e)
                # user_create_location(routing, account_id)
              end
            end

            # GET /api/v1/accounts/[account_id]/rooms DONEE
            routing.on 'rooms' do
              routing.get do
                output = Cryal::AccountService::Room::FetchOne.call(routing, account_id)
                not_found(routing, 'DB Error') if output.nil?
                response.status = 200
                output.to_json
                # user_fetch_rooms(routing, account_id)
              end
            end

            # POST /api/v1/accounts/[account_id]/createroom DONEE
            routing.on 'createroom' do
              routing.post do
                # user_create_room(routing, account_id)
                json = JSON.parse(routing.body.read)
                output = Cryal::AccountService::Room::Create.call(routing, json, account_id)
                response.status = 201
                { message: 'Room created', data: output }.to_json
              rescue StandardError => e
                log_and_handle_error(routing, json, e)
                # Cryal::AccountService::Room::Join.call(routing, account_id)
              end
            end

            # POST /api/v1/accounts/[account_id]/joinroom DONEE
            routing.on 'joinroom' do
              routing.post do
                # user_join_room(routing, account_id)
                json = JSON.parse(routing.body.read)
                output = Cryal::AccountService::Room::Join.call(routing, json, account_id)
                response.status = 201
                { message: 'Room Join Successfully', data: output }.to_json
              rescue StandardError => e
                log_and_handle_error(routing, json, e)
              end
            end

            # POST /api/v1/accounts/[account_id]/plans
            routing.on 'plans' do # rubocop:disable Metrics/BlockLength
              # POST /api/v1/accounts/[account_id]/plans/create_plan DONEE
              routing.on 'create_plan' do
                routing.post do
                  # user_create_plan(routing, account_id)
                  json = JSON.parse(routing.body.read)
                  output = Cryal::AccountService::Plans::Create.call(routing, json, account_id)
                  response.status = 201
                  { message: 'Plan saved', data: output }.to_json
                rescue StandardError => e
                  log_and_handle_error(routing, json, e)
                end
              end

              # GET /api/v1/accounts/[account_id]/plans/fetch DONEE
              routing.on 'fetch' do
                routing.get do
                  # user_fetch_plans(routing, account_id)
                  output = Cryal::AccountService::Plans::FetchOne.call(routing, account_id)
                  response.status = 200
                  output.to_json
                end
              end

              # api/v1/accounts/[account_id]/plans/[plan_id]
              routing.on String do |plan_id|
                routing.on 'waypoints' do
                  # POST /api/v1/accounts/[account_id]/plans/[plan_id]/waypoints DONEE
                  routing.post do
                    # user_create_waypoint(routing, account_id, plan_id)
                    json = JSON.parse(routing.body.read)
                    output = Cryal::AccountService::Waypoint::Create.call(routing, json, account_id, plan_id)
                    response.status = 201
                    { message: 'Waypoint saved', data: output }.to_json
                  rescue StandardError => e
                    log_and_handle_error(routing, json, e)
                  end

                  # GET /api/v1/accounts/[account_id]/plans/[plan_id]/waypoints DONE
                  routing.get do
                    # user_fetch_waypoints(routing, account_id, plan_id)
                    output = Cryal::AccountService::Waypoint::FetchOne.call(routing, account_id, plan_id)
                    response.status = 200
                    output.to_json
                  end
                end
              end
            end
          end

          # GET /api/v1/accounts DONEE
          routing.get do
            output = Cryal::GlobalActions::Account::FetchAll.call(routing)
            response.status = 200
            output.to_json
          end

          # POST /api/v1/accounts DONEE
          routing.post do
            json = JSON.parse(routing.body.read)
            output = Cryal::GlobalActions::Account::Create.call(json)

            response.status = 201
            { message: 'Account saved', data: output }.to_json
          rescue StandardError => e
            log_and_handle_error(routing, json, e)
          end
        end
        routing.on 'rooms' do
          routing.on String do |room_id|
            routing.is do
              # GET /api/v1/rooms/[room_id]
              routing.get do
                output = Cryal::GlobalActions::Room::FetchOne.call(routing, room_id)
                response.status = 200
                output.to_json
                # global_fetch_room(routing, room_id)
              end
            end
          end
          # GET /api/v1/rooms DONEE
          routing.get do
            output = Cryal::GlobalActions::Room::FetchAll.call(routing)
            response.status = 200
            output.to_json
            # global_fetch_room_all(routing)
          end
        end

        routing.on 'userrooms' do
          # GET /api/v1/userrooms DONE
          routing.get do
            output = Cryal::GlobalActions::UserRooms::FetchAll.call(routing)
            response.status = 200
            output.to_json
          end
        end
      end
    end

    def not_found(routing, message)
      routing.halt 404, { message: }.to_json
    end

    def log_and_handle_error(routing, json, err)
      if err.is_a?(Sequel::MassAssignmentRestriction)
        Api.logger.warn "Mass Assignment: #{json.keys}"
        routing.halt 400, { message: 'Mass Assignment Error' }.to_json
      else
        Api.logger.error "Error: #{err.message}"
        routing.halt 500, { message: 'Internal Server Error' }.to_json
      end
    end
  end

  def log_and_handle_error(routing, json, err)
    if err.is_a?(Sequel::MassAssignmentRestriction)
      Api.logger.warn "Mass Assignment: #{json.keys}"
      routing.halt 400, { message: 'Mass Assignment Error' }.to_json
    else
      Api.logger.error "Error: #{err.message}"
      routing.halt 500, { message: 'Internal Server Error' }.to_json
    end
  end

  def not_found(routing, message, err = 404)
    routing.halt err, { message: }.to_json
  end
end
