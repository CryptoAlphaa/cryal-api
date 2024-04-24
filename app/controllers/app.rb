require 'sequel'
require 'roda'
require 'json'
require_relative '../models/location.rb'
require_relative '../models/room.rb'
require_relative '../models/target.rb'
require_relative '../models/user_room.rb'
require_relative '../models/user.rb'

module Cryal
  class Api < Roda
    plugin :environments
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'Welcome to Cryal API' }.to_json
      end

      routing.on 'api/v1' do
        routing.on 'locations' do
          routing.get do # GET api/v1/locations
            response.status = 200
            output = { location_ids: Location.all }
            JSON.pretty_generate(output)
          end

          routing.get do # GET api/v1/locations/[location_id]
            location = Location.where(id: location_id).first
            location ? JSON.pretty_generate(location) : raise('Location not found')
          rescue StandardError
            routing.halt(404, { message: 'Location not found' }.to_json)
          end

          routing.post do # POST api/v1/locations
            new_data = JSON.parse(routing.body.read)
            new_location = Location.new(new_data)

            if new_location.save
              response.status = 201
              { message: 'Location saved', id: new_location.id }.to_json
            else
              routing.halt 400, { message: 'Could not save location' }.to_json
            end
          end
        end
      end

      routing.on 'rooms' do
        routing.get do # GET api/v1/rooms
          response.status = 200
          output = { room_ids: room.all }
          JSON.pretty_generate(output)
        end

        routing.get do # GET api/v1/rooms/[room_id]
          room = room.where(id: room_id).first
          room ? JSON.pretty_generate(room) : raise('room not found')
        rescue StandardError
          routing.halt(404, { message: 'room not found' }.to_json)
        end
      end

      # this routing is to get all locations associated with a room
      routing.get do # GET api/v1/rooms/[room_id]/locations
        room = room.where(id: room_id).first

        room || raise('room not found')
      rescue StandardError
        routing.halt(404, { message: 'room not found' }.to_json)
      end

      all_locations = Location.where(room_id: room_id)
      all_locations ? JSON.pretty_generate(all_locations) : raise('Locations not found')
    rescue StandardError
      routing.halt(404, { message: 'Locations not found' }.to_json)
    end
  end

    #   routing.post do # POST api/v1/rooms
    #     new_data = JSON.parse(routing.body.read)
    #     new_room = room.new(new_data)

    #     if new_room.save
    #       response.status = 201
    #       { message: 'room saved', id: new_room.id }.to_json
    #     else
    #       routing.halt 400, { message: 'Could not save room' }.to_json
    #     end
    #   end
end
