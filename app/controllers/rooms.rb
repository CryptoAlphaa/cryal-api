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
                        packet = rooms
                    else
                        rooms = Cryal::AccountService::Room::FetchOne.call(@auth_account, room_id)
                        # get all users in the room
                        accounts = rooms.user_rooms.map do |user_room|
                            user = user_room.account
                            { user_id: user.account_id, username: user.username }
                        end
                        packet = { rooms: rooms, accounts: accounts, plans: rooms.plans}
                    end
                    response.status = 200
                    { message: 'Success', data: packet }.to_json
                    # { message: 'Success', data: {rooms => rooms, accounts => accounts} }.to_json
                rescue Cryal::AccountService::Room::FetchAll::ForbiddenError => e
                    routing.halt 403, { message: 'Forbidden' }.to_json
                rescue Cryal::AccountService::Room::FetchOne::NotFoundError => e
                    routing.halt 404, { message: 'Not Found'}.to_json
                end
            end

            # POST /api/v1/rooms/createroom
            routing.on 'createroom' do
                routing.post do
                    room_data = JSON.parse(routing.body.read)
                    output = Cryal::AccountService::Room::Create.call(@auth_account, room_data)
                    response.status = 201
                    { message: 'Room created', data: output }.to_json
                rescue Cryal::AccountService::Room::Create::ForbiddenError => e
                    routing.halt 403, { message: e.message }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, room_data, e)
                end
            end

            # POST /api/v1/rooms/joinroom
            routing.on 'joinroom' do
                routing.post do
                    join_request = JSON.parse(routing.body.read)
                    output = Cryal::AccountService::Room::Join.call(@auth_account, join_request)
                    response.status = 201
                    { message: 'Room Join Successfully', data: output }.to_json
                rescue Cryal::AccountService::Room::Join::ForbiddenError => e
                    routing.halt 403, { message: e.message }.to_json
                rescue Cryal::AccountService::Room::Join::NotFoundError => e
                    routing.halt 404, { message: e.message }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, join_request, e)
                end
            end

            routing.on String do |room_id|
                # p "routing inspect: #{routing.inspect}"
                routing.on 'plans' do
                    routing.is do
                        # GET /api/v1/rooms/room_id/plans?plan_name="some_plan_name"
                        routing.get do
                            plan_name = routing.params['plan_name']
                            puts "Plan name in backend: #{plan_name}"
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

                    routing.on String do |plan_id|
                        routing.on 'waypoints' do
                            routing.is do
                                # POST /api/v1/rooms/room_id/plans/plan_id/waypoints
                                routing.post do
                                    new_waypoint = JSON.parse(routing.body.read)
                                    output = Cryal::AccountService::Waypoint::Create.call(@auth_account, room_id, plan_id, new_waypoint)
                                    response.status = 201
                                    { message: 'Waypoint saved', data: output }.to_json
                                    rescue Cryal::AccountService::Waypoint::Create::ForbiddenError => e
                                        routing.halt 403, { message: e.message }.to_json
                                    rescue Cryal::AccountService::Waypoint::Create::NotFoundError => e
                                        routing.halt 404, { message: e.message }.to_json
                                    rescue StandardError => e
                                        log_and_handle_error(routing, new_waypoint, e)
                                end

                                # GET /api/v1/rooms/room_id/plans/plan_id/waypoints?waypoint_number=1
                                routing.get do
                                    waypoint_number = routing.params['waypoint_number']
                                    waypoints = Cryal::AccountService::Waypoint::Fetch.call(@auth_account, room_id, plan_id, waypoint_number)
                                    response.status = 200
                                    { message: 'Success', data: waypoints }.to_json
                                    rescue Cryal::AccountService::Waypoint::Fetch::ForbiddenError => e
                                        routing.halt 403, { message: e.message }.to_json
                                    rescue Cryal::AccountService::Waypoint::Fetch::NotFoundError => e
                                        routing.halt 404, { message: e.message }.to_json
                                    rescue StandardError => e
                                        routing.halt 500, { message: 'API Server Error' }.to_json
                                end
                            end
                        end
                    end
                end    
            end
        end
    end
end
