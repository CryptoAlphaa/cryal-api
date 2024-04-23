require 'sequel'
require 'roda'
require 'json'
require_relative '../models/track_session'
require_relative '../models/location'

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

      routing.on 'sessions' do
        routing.get do # GET api/v1/sessions
          response.status = 200
          output = { session_ids: TrackSession.all }
          JSON.pretty_generate(output)
        end

        routing.get do # GET api/v1/sessions/[session_id]
          session = TrackSession.where(id: session_id).first
          session ? JSON.pretty_generate(session) : raise('Session not found')
        rescue StandardError
          routing.halt(404, { message: 'Session not found' }.to_json)
        end
      end

      # this routing is to get all locations associated with a session
      routing.get do # GET api/v1/sessions/[session_id]/locations
        session = TrackSession.where(id: session_id).first

        session || raise('Session not found')
      rescue StandardError
        routing.halt(404, { message: 'Session not found' }.to_json)
      end

      all_locations = Location.where(session_id: session_id)
      all_locations ? JSON.pretty_generate(all_locations) : raise('Locations not found')
    rescue StandardError
      routing.halt(404, { message: 'Locations not found' }.to_json)
    end
  end

      routing.post do # POST api/v1/sessions
        new_data = JSON.parse(routing.body.read)
        new_session = TrackSession.new(new_data)

        if new_session.save
          response.status = 201
          { message: 'Session saved', id: new_session.id }.to_json
        else
          routing.halt 400, { message: 'Could not save session' }.to_json
        end
      end
end
