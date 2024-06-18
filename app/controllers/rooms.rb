# frozen_string_literal: true

require 'roda'
require_relative './app'

module Cryal
  # Web controller for Credence API
    class Api < Roda
        include Cryal
        route('rooms') do |routing|
            routing.halt(403, UNAUTH_MSG) unless @auth_account
            # make three routing, get all rooms associated, create room, join room
            # GET /api/v1/rooms?room_id=1
            routing.is do
                routing.get do
                    room_id = routing.params['room_id']
                    if room_id.nil?
                        packet = AccountService::Room::FetchAll.call(requestor: @auth_account)
                    else
                        packet = AccountService::Room::FetchOne.call(@auth, room_id)
                    end
                    response.status = 200
                    { message: 'Success', data: packet }.to_json
                    # { message: 'Success', data: {rooms => rooms, accounts => accounts} }.to_json
                rescue AccountService::Room::FetchAll::ForbiddenError => e
                    routing.halt 403, { message: 'Forbidden' }.to_json
                rescue AccountService::Room::FetchOne::NotFoundError => e
                    routing.halt 404, { message: 'Not Found'}.to_json
                end
            end

            # DELETE /api/v1/rooms/delete?room_id=1
            routing.on 'delete' do
                routing.delete do
                    room_id = routing.params['room_id']
                    output = AccountService::Room::Delete.call(@auth, room_id)
                    response.status = 200
                    { message: 'Room deleted', data: output }.to_json
                rescue AccountService::Room::Delete::ForbiddenError => e
                    routing.halt 403, { message: e.message }.to_json
                rescue AccountService::Room::Delete::NotFoundError => e
                    routing.halt 404, { message: e.message }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, room_id, e)
                end
            end

            # DELETE /api/v1/rooms/exit?room_id=1
            routing.on 'exit' do
                routing.delete do
                    room_id = routing.params['room_id']
                    output = AccountService::Room::Exit.call(@auth, room_id)
                    response.status = 200
                    { message: 'Room exited' }.to_json
                rescue AccountService::Room::Exit::ForbiddenError => e
                    routing.halt 403, { message: e.message }.to_json
                rescue AccountService::Room::Exit::NotFoundError => e
                    routing.halt 404, { message: e.message }.to_json
                rescue AccountService::Room::Exit::YouAreAdminError => e
                    routing.halt 403, { message: e.message }.to_json
                end
            end

            # POST /api/v1/rooms/createroom
            routing.on 'createroom' do
                routing.post do
                    room_data = JSON.parse(routing.body.read)
                    output = AccountService::Room::Create.call(@auth, room_data)
                    response.status = 201
                    { message: 'Room created', data: output }.to_json
                rescue AccountService::Room::Create::ForbiddenError => e
                    routing.halt 403, { message: e.message }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, room_data, e)
                end
            end

            # POST /api/v1/rooms/joinroom
            routing.on 'joinroom' do
                routing.post do
                    join_request = JSON.parse(routing.body.read)
                    output = AccountService::Room::Join.call(@auth, join_request)
                    response.status = 201
                    { message: 'Room Join Successfully', data: output }.to_json
                rescue AccountService::Room::Join::ForbiddenError => e
                    routing.halt 403, { message: e.message }.to_json
                rescue AccountService::Room::Join::NotFoundError => e
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
                            # puts "Plan name in backend: #{plan_name}"
                            plans = AccountService::Plans::Fetch.call(@auth, room_id, plan_name)
                            response.status = 200
                            { message: 'Success', data: plans }.to_json
                            rescue AccountService::Plans::Fetch::ForbiddenError => e
                                routing.halt 403, { message: e.message }.to_json
                            rescue AccountService::Plans::Fetch::PlansNotFoundError => e
                                routing.halt 404, { message: e.message }.to_json
                            rescue StandardError => e
                                routing.halt 500, { message: 'API Server Error' }.to_json
                        end
                        # delete /api/v1/rooms/room_id/plans?plan_name="some_plan_name"
                        routing.delete do
                            plan_name = routing.params['plan_name']
                            output = AccountService::Plans::Delete.call(@auth, room_id, plan_name)
                            response.status = 200
                            { message: 'Plan deleted', data: output }.to_json
                            rescue AccountService::Plans::Delete::ForbiddenError => e
                                routing.halt 403, { message: e.message }.to_json
                            rescue AccountService::Plans::Delete::NotFoundError => e
                                routing.halt 404, { message: e.message }.to_json
                            rescue StandardError => e
                                routing.halt 500, { message: 'API Server Error' }.to_json
                        end
                        # POST /api/v1/rooms/room_id/plans
                        routing.post do
                            new_plan = JSON.parse(routing.body.read)
                            output = AccountService::Plans::Create.call(@auth, room_id, new_plan)
                            response.status = 201
                            { message: 'Plan saved', data: output }.to_json
                            rescue AccountService::Plans::Create::ForbiddenError => e
                                routing.halt 403, { message: e.message }.to_json
                            rescue AccountService::Plans::Create::NotFoundError => e
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
                                    output = AccountService::Waypoint::Create.call(@auth, room_id, plan_id, new_waypoint)
                                    response.status = 201
                                    { message: 'Waypoint saved', data: output }.to_json
                                    rescue AccountService::Waypoint::Create::ForbiddenError => e
                                        routing.halt 403, { message: e.message }.to_json
                                    rescue AccountService::Waypoint::Create::NotFoundError => e
                                        routing.halt 404, { message: e.message }.to_json
                                    rescue StandardError => e
                                        log_and_handle_error(routing, new_waypoint, e)
                                end

                                # GET /api/v1/rooms/room_id/plans/plan_id/waypoints?waypoint_number=1
                                routing.get do
                                    waypoint_number = routing.params['waypoint_number']
                                    waypoints = AccountService::Waypoint::Fetch.call(@auth, room_id, plan_id, waypoint_number)
                                    response.status = 200
                                    { message: 'Success', data: waypoints }.to_json
                                    rescue AccountService::Waypoint::Fetch::ForbiddenError => e
                                        routing.halt 403, { message: e.message }.to_json
                                    rescue AccountService::Waypoint::Fetch::NotFoundError => e
                                        routing.halt 404, { message: e.message }.to_json
                                    rescue StandardError => e
                                        routing.halt 500, { message: 'API Server Error' }.to_json
                                end

                                # DELETE /api/v1/rooms/room_id/plans/plan_id/waypoints?waypoint_id=...
                                routing.delete do
                                    waypoint_id = routing.params['waypoint_id']
                                    output = AccountService::Waypoint::Delete.call(@auth, room_id, plan_id, waypoint_id)
                                    response.status = 200
                                    { message: 'Waypoint deleted'}.to_json
                                    rescue AccountService::Waypoint::Delete::ForbiddenError => e
                                        routing.halt 403, { message: e.message }.to_json
                                    rescue AccountService::Waypoint::Delete::NotFoundError => e
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
