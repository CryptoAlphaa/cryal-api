# frozen_string_literal: true

require 'sequel'
require 'roda'
require 'json'

module Cryal
  # Class for designing the API
  class Api < Roda # rubocop:disable Metrics/ClassLength
    plugin :environments
    plugin :halt

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'Welcome to Cryal APIs' }.to_json
      end

      routing.on 'api' do # rubocop:disable Metrics/BlockLength
        routing.on 'v1' do # rubocop:disable Metrics/BlockLength
          routing.on 'users' do # rubocop:disable Metrics/BlockLength
            routing.on String do |user_id| # rubocop:disable Metrics/BlockLength
              routing.on 'createroom' do
                # post api/v1/users/[id]/createroom
                routing.post do
                  new_data = JSON.parse(routing.body.read)
                  new_data['user_id'] = user_id.to_i
                  new_target = Room.new(new_data)
                  raise('Could not save room') unless new_target.save

                  response.status = 201
                  { message: 'room saved', data: new_target }.to_json
                rescue StandardError => e
                  routing.halt 404, { message: 'DB Error', error: e }.to_json
                end
              end

              routing.on 'joinroom' do
                # post api/v1/users/[id]/joinroom
                routing.post do
                  new_data = JSON.parse(routing.body.read)
                  new_data['user_id'] = user_id.to_i
                  new_data['active'] = true
                  new_target = User_Room.new(new_data)

                  raise('Could Join Room') unless new_target.save

                  response.status = 201
                  { message: 'Room Joinned Succesfully', data: new_target }.to_json
                rescue StandardError => e
                  routing.halt 404, { message: 'DB Error', error: e }.to_json
                end
              end

              routing.on 'location' do # rubocop:disable Metrics/BlockLength
                routing.on String do |location_id|
                  # get api/v1/location/[id]
                  routing.get do
                    output = Location.first(location_id:)
                    output.nil? raise 'Location not found'
                    response.status = 200
                    output.to_json
                  rescue StandardError => e
                    routing.halt 404, { message: 'Location not found', error: e }.to_json
                  end
                end
                # get api/vi/users/[id]/location
                routing.get do
                  output = { data: User.first(user_id:).locations }
                  JSON.pretty_generate(output)
                rescue StandardError => e
                  routing.halt 404, { message: 'DB Error', error: e }.to_json
                end

                # post api/vi/users/[id]/location
                routing.post do
                  new_data = JSON.parse(routing.body.read)
                  new_data['cur_lat'] = new_data['cur_lat'].to_f
                  new_data['cur_long'] = new_data['cur_long'].to_f
                  new_data['user_id'] = user_id.to_i
                  new_loc = Location.new(new_data)

                  raise('Could not save Location') unless new_loc.save

                  response.status = 201
                  { message: 'Location saved', data: new_loc }.to_json
                rescue StandardError => e
                  routing.halt 404, { message: 'DB Error', error: e }.to_json
                end
              end

              # get api/v1/users/[id]
              routing.get do
                output = User.first(user_id:)
                output.nil? raise 'User not found'
                response.status = 200
                output.to_json
              rescue StandardError => e
                routing.halt 404, { message: 'Users not found', error: e }.to_json
              end
            end

            # get api/v1/users
            routing.get do
              output = { data: User.all }
              JSON.pretty_generate(output)
            rescue StandardError => e
              routing.halt 404, { message: 'something wrong plis fix get users', errorL: e }.to_json
            end

            # post api/v1/users
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_user = User.new(new_data)
              raise('Could not save User') unless new_user.save

              response.status = 201
              { message: 'User saved', data: new_user }.to_json
            rescue StandardError => e
              routing.halt 404, { message: 'Can\'t load any users', error: e }.to_json
            end
          end
          response.status = 200
          { message: 'Welcome to Cryal api/v1' }.to_json

          routing.on 'rooms' do
            routing.on String do |room_id|
              # get api/v1/rooms/[id]
              routing.get do
                output = Room.first(room_id:)
                output.nil? raise 'Room not found'
                response.status = 200
                output.to_json
              rescue StandardError => e
                routing.halt 404, { message: 'Room not found', error: e }.to_json
              end
            end
            # get api/v1/rooms
            routing.get do
              output = { data: Room.all }
              JSON.pretty_generate(output)
            rescue StandardError => e
              routing.halt 404, { message: 'something wrong plis fix get rooms', errorL: e }.to_json
            end
          end

          routing.on 'location' do
            routing.on String do |location_id|
              # get api/v1/location/[id]
              routing.get do
                output = Location.first(location_id:)
                output.nil? raise 'Location not found'
                response.status = 200
                output.to_json
              rescue StandardError => e
                routing.halt 404, { message: 'Location not found', error: e }.to_json
              end
            end
            # get api/v1/location
            routing.get do
              output = { data: Location.all }
              JSON.pretty_generate(output)
            rescue StandardError => e
              routing.halt 404, { message: 'something wrong plis fix get location', errorL: e }.to_json
            end
          end

          routing.on 'user_rooms' do
            routing.on String do |user_room_id|
              # get api/v1/user_room/[id]
              routing.get do
                output = User_Room.first(user_room_id:)
                output.nil? raise 'User_Room not found'
                response.status = 200
                output.to_json
              rescue StandardError => e
                routing.halt 404, { message: 'User_Room not found', error: e }.to_json
              end
            end
            # get api/v1/userroom
            routing.get do
              output = { data: User_Room.all }
              JSON.pretty_generate(output)
            rescue StandardError => e
              routing.halt 404, { message: 'something wrong plis fix get rooms', errorL: e }.to_json
            end
          end

          routing.on 'targets' do
            routing.on String do |target_id|
              # get api/v1/targets/[id]
              routing.get do
                output = Target.first(target_id:)
                output.nil? raise 'Target not found'
                response.status = 200
                output.to_json
              rescue StandardError => e
                routing.halt 404, { message: 'Target not found', error: e }.to_json
              end
            end

            # get api/v1/targets
            routing.get do
              output = { data: Target.all }
              JSON.pretty_generate(output)
            rescue StandardError => e
              routing.halt 404, { message: 'something wrong plis fix get target', errorL: e }.to_json
            end

            # post api/v1/targets
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_target = Target.new(new_data)
              raise('Could not save Target') unless new_target.save

              response.status = 201
              { message: 'Target saved', data: new_target }.to_json
            rescue StandardError => e
              routing.halt 404, { message: 'Can\'t load any Target', error: e }.to_json
            end
          end
        end
        response.status = 200
        { message: 'Welcome to Cryal api' }.to_json
      end
    end
  end
end
