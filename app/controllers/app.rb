# frozen_string_literal: true
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

    # Naming Convention [Route]_[Task]_[Object]_[AdditionalInfo]

    # def user_fetch_user(routing, account_id)
    #   output = Account.first(account_id:)
    #   not_found(routing, 'Account not found') if output.nil?
    #   response.status = 200
    #   output.to_json
    # end

    # def user_fetch_locations(routing, account_id)
    #   output = Account.first(account_id:)
    #   not_found(routing, 'Account not found') if output.nil?
    #   locations = output.locations
    #   response.status = 200
    #   locations.to_json
    # end

    # def user_create_location(routing, account_id)
    #   Account = Account.first(account_id:)
    #   not_found(routing, 'Account not found') if Account.nil?
    #   location = JSON.parse(routing.body.read)
    #   location = Account.add_location(location)
    #   response.status = 201
    #   { message: 'Location saved', data: location }.to_json
    # rescue StandardError => e
    #   log_and_handle_error(routing, location, e)
    # end

    # # TODO : Fix model first
    # def user_fetch_rooms(routing, account_id)
    #   output = { data: Account.first(account_id:).rooms }
    #   not_found(routing, 'DB Error') if output.nil?
    #   response.status = 200
    #   output.to_json
    # end

    # def user_create_room(routing, account_id)
    #   Account = Account.first(account_id:)
    #   not_found(routing, 'Account not found') if Account.nil?
    #   room = JSON.parse(routing.body.read)
    #   room = Account.add_room(room)
    #   response.status = 201
    #   { message: 'Room saved', data: room }.to_json
    # rescue StandardError => e
    #   log_and_handle_error(routing, room, e)
    # end

    # def user_join_room(routing, account_id)
    #   Account = Account.first(account_id:)
    #   not_found(routing, 'Account not found') if Account.nil?
    #   user_room = JSON.parse(routing.body.read)
    #   user_room = Account.add_user_room(user_room)
    #   response.status = 201
    #   { message: 'Room Join Successfully', data: user_room }.to_json
    # rescue StandardError => e
    #   log_and_handle_error(routing, user_room, e)
    # end

    # def user_create_plan(routing, account_id)
    #   Account = Account.first(account_id:)
    #   not_found(routing, 'Account not found') if Account.nil?
    #   plan = JSON.parse(routing.body.read)
    #   room = Room.first(room_name: plan['room_name'])
    #   not_found(routing, 'Room not found') if room.nil?
    #   user_room = User_Room.first(account_id: Account.account_id, room_id: room.room_id)
    #   not_found(routing, 'Account not in the room') if user_room.nil?
    #   plan.delete('room_name')
    #   final_plan = room.add_plan(plan)
    #   response.status = 201
    #   { message: 'Plan saved', data: final_plan }.to_json
    # rescue StandardError => e
    #   log_and_handle_error(routing, plan, e)
    # end

    # def user_fetch_plans(routing, account_id)
    #   Account = Account.first(account_id:)
    #   not_found(routing, 'Account not found') if Account.nil?
    #   search = routing.params['room_name']
    #   room = Room.first(room_name: search)
    #   not_found(routing, 'Room not found') if room.nil?
    #   user_room = User_Room.first(account_id: Account.account_id, room_id: room.room_id)
    #   not_found(routing, 'Account not in the room') if user_room.nil?
    #   all_plans = room.plans
    #   # Extract only the plan_name and plan_description
    #   output = []
    #   all_plans.each do |plan|
    #     output.push(plan.to_json)
    #   end
    #   response.status = 200
    #   output.to_json
    # end

    # def user_create_waypoint(routing, account_id, plan_id)
    #   Account = Account.first(account_id:)
    #   not_found(routing, 'Account not found') if Account.nil?
    #   plan = Plan.first(plan_id:)
    #   not_found(routing, 'Plan not found') if plan.nil?
    #   waypoint = JSON.parse(routing.body.read)
    #   last_waypoint_number = Waypoint.where(plan_id: plan.plan_id).max(:waypoint_number) || 0
    #   new_waypoint_number = last_waypoint_number + 1
    #   # delete waypoint number field if it exists
    #   waypoint.delete('waypoint_number')
    #   waypoint[:waypoint_number] = new_waypoint_number
    #   final_waypoint = plan.add_waypoint(waypoint)

    #   response.status = 201
    #   { message: 'Waypoint saved', data: final_waypoint }.to_json
    # rescue StandardError => e
    #   log_and_handle_error(routing, waypoint, e)
    # end

    # def user_fetch_waypoints(routing, account_id, plan_id)
    #   Account = Account.first(account_id:)
    #   not_found(routing, 'Account not found') if Account.nil?
    #   plan = Plan.first(plan_id:)
    #   not_found(routing, 'Plan not found') if plan.nil?
    #   waypoints = plan.waypoints
    #   response.status = 200
    #   waypoints.to_json
    # end

    # def global_create_user(routing)
    #   Account = JSON.parse(routing.body.read)
    #   final_user = Account.new(Account)
    #   final_user.save
    #   response.status = 201
    #   { message: 'Account saved', data: final_user }.to_json
    # rescue StandardError => e
    #   log_and_handle_error(routing, Account, e)
    # end

    # def global_fetch_users(_routing)
    #   output = { data: Account.all }
    #   output.to_json
    # end

    # def global_fetch_room(routing, room_id)
    #   output = Room.first(room_id:)
    #   not_found(routing, 'Room not found') if output.nil?
    #   response.status = 200
    #   output.to_json
    # end

    # def global_fetch_room_all(_routing)
    #   output = { data: Room.all }
    #   output.to_json
    # end

    # def global_fetch_userrooms(_routing)
    #   output = { data: User_Room.all }
    #   output.to_json
    # end

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

  def not_found(routing, message)
    routing.halt 404, { message: }.to_json
  end
end
