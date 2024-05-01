# frozen_string_literal: true

require 'sequel'
require 'roda'
require 'json'

module Cryal
  # Class for designing the API
  class Api < Roda
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
        routing.on 'users' do # rubocop:disable Metrics/BlockLength
          routing.on String do |user_id| # rubocop:disable Metrics/BlockLength
            routing.is do
              # GET /api/v1/users/[user_id] DONE
              routing.get do
                user_fetch_user(routing, user_id)
              end
            end

            routing.on 'locations' do
              # GET /api/v1/users/[user_id]/locations DONE
              routing.get do
                user_fetch_locations(routing, user_id)
              end

              # POST /api/v1/users/[user_id]/locations DONE
              routing.post do
                user_create_location(routing, user_id)
              end
            end

            # GET /api/v1/users/[user_id]/rooms # BROKEN, TO DO. FIX MODEL
            routing.on 'rooms' do
              routing.get do
                user_fetch_rooms(routing, user_id)
              end
            end

            # POST /api/v1/users/[user_id]/createroom DONE
            routing.on 'createroom' do
              routing.post do
                user_create_room(routing, user_id)
              end
            end

            # POST /api/v1/users/[user_id]/joinroom DONE
            routing.on 'joinroom' do
              routing.post do
                user_join_room(routing, user_id)
              end
            end

          # POST /api/v1/users/[user_id]/createplan
          routing.on 'createplan' do
            routing.post do
              user_create_plan(routing, user_id)
            end
          end
        end

          # GET /api/v1/users DONE
          routing.get do
            global_fetch_users(routing)
          end

          # POST /api/v1/users DONE
          routing.post do
            global_create_user(routing)
          end
        end

        # GET /api/v1/rooms DONE
        routing.on 'rooms' do
          routing.on String do |room_id|
            routing.is do
              # GET /api/v1/rooms/[room_id]
              routing.get do
                global_fetch_room(routing, room_id)
              end
            end
          end
          # GET /api/v1/rooms DONE
          routing.get do
            global_fetch_room_all(routing)
          end
        end

        routing.on 'userrooms' do
          # GET /api/v1/userrooms DONE
          routing.get do
            global_fetch_userrooms(routing)
          end
        end
      end
    end

    # targets belom di kerjain
    # targets belom di kerjain
    # targets belom di kerjain

    private

    # Naming Convention [Route]_[Task]_[Object]_[AdditionalInfo]

    def user_fetch_user(routing, user_id)
      output = User.first(user_id:)
      not_found(routing, 'User not found') if output.nil?
      response.status = 200
      output.to_json
    end

    def user_fetch_locations(routing, user_id)
      output = User.first(user_id:)
      not_found(routing, 'User not found') if output.nil?
      locations = output.locations
      response.status = 200
      locations.to_json
    end

    def user_create_location(routing, user_id) # rubocop:disable Metrics/AbcSize
      user = User.first(user_id:)
      not_found(routing, 'User not found') if user.nil?
      location = JSON.parse(routing.body.read)
      location = user.add_location(location)

      if location
        response.status = 201
        { message: 'Location saved', data: location.to_json }.to_json
      else
        internal_server_error('Could not save Location')
      end
    end

    # TODO : Fix model first
    def user_fetch_rooms(routing, user_id)
      output = { data: User.first(user_id:).rooms }
      not_found(routing, 'DB Error') if output.nil?
      response.status = 200
      output.to_json
    end

    def user_create_room(routing, user_id)
      user = User.first(user_id:)
      not_found(routing, 'User not found') if user.nil?
      room = JSON.parse(routing.body.read)
      room = user.add_room(room)

      if room
        response.status = 201
        { message: 'Room saved', data: room.to_json }.to_json
      else
        internal_server_error('Could not save Room')
      end
    end

    def user_join_room(routing, user_id)
      user = User.first(user_id: user_id)
      not_found(routing, 'User not found') if user.nil?
      user_room = JSON.parse(routing.body.read)
      user_room = user.add_user_room(user_room)
      if user_room
        response.status = 201
        { message: 'Room Join Successfully', data: user_room }.to_json
      else
        internal_server_error('Could not save User_Room')
      end
    end

    def user_create_plan(routing, user_id)
      user = User.first(user_id:)
      not_found(routing, 'User not found') if user.nil?

      plan = JSON.parse(routing.body.read)
      # Get the room first

      # Plans are made inside a room, so we need to get the room first

      plan = JSON.parse(routing.body.read)
      plan = user.add_plan(plan)
    end

    def global_create_user(routing)
      user = JSON.parse(routing.body.read)
      user = User.new(user)
      if user.save
        response.status = 201
        { message: 'User saved', data: user }.to_json
        user.to_json
      else
        internal_server_error('Failed to create user')
      end
    end

    def global_fetch_users(_routing)
      output = { data: User.all }
      output.to_json
    end

    def global_fetch_room(routing, room_id)
      output = Room.first(room_id:)
      not_found(routing, 'Room not found') if output.nil?
      response.status = 200
      output.to_json
    end

    def global_fetch_room_all(_routing)
      output = { data: Room.all }
      output.to_json
    end

    def global_fetch_userrooms(_routing)
      output = { data: User_Room.all }
      output.to_json
    end

    def not_found(routing, message)
      routing.halt 404, { message: }.to_json
    end

    def internal_server_error(message)
      routing.halt 500, { message: }.to_json
    end
  end
end
