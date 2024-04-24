require 'sequel'
require 'roda'
require 'json'

module Cryal
  class Api < Roda
    plugin :environments
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'Welcome to Cryal APIs' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'users' do
            routing.on String do |user_id|
              routing.on 'location' do
                #post api/vi/users/[id]/location
                routing.post do
                  new_data = JSON.parse(routing.body.read)
                  print('0')
                  user = User.first(user_id: user_id)
                  # puts(loc.methods)
                  print('1')
                  new_loc = user.add_location(new_data)
                  print('2')
                  if new_loc
                    response.status = 201
                    { message: 'Location saved', data: new_loc }.to_json
                  else
                    routing.halt 400, 'Could not save document'
                  end

                rescue StandardError => e
                  routing.halt 400, { message: e.message }.to_json
                end
              end

              #get api/v1/users/[id]
              routing.get do
                output = User.first(user_id: user_id)
                response.status = 200
                output.to_json
              rescue StandardError
                routing.halt 404, { message: 'Users not found' }.to_json
              end
            end


            #get api/v1/users
            routing.get do
              output = { data: User.all }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, { message: 'som ting wong plis fix get users' }.to_json
            end

            #post api/v1/users
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_user = User.new(new_data)
              raise('Could not save User') unless new_user.save

              response.status = 201
              { message: 'User saved', data: new_user }.to_json
            rescue StandardError
              routing.halt 400, { message: 'Can\'t load any users' }.to_json
            end
          end
          response.status = 200
          { message: 'Welcome to Cryal api/v1' }.to_json
        end
        response.status = 200
        { message: 'Welcome to Cryal api' }.to_json
      end
    end
  end
end
          # routing.on 'locations' do
          #   routing.get do # GET api/v1/locations
          #     response.status = 200
          #     output = { location_ids: Location.all }
          #     JSON.pretty_generate(output)
          #   end

          #   routing.get do # GET api/v1/locations/[location_id]
          #     location = Location.where(id: location_id).first
          #     location ? JSON.pretty_generate(location) : raise('Location not found')
          #   rescue StandardError
          #     routing.halt(404, { message: 'Location not found' }.to_json)
          #   end

          #   routing.post do # POST api/v1/locations
          #     new_data = JSON.parse(routing.body.read)
          #     new_location = Location.new(new_data)

          #     if new_location.save
          #       response.status = 201
          #       { message: 'Location saved', id: new_location.id }.to_json
          #     else
          #       routing.halt 400, { message: 'Could not save location' }.to_json
          #     end
          #   end
          # end
  #     routing.on 'sessions' do
  #       routing.get do # GET api/v1/sessions
  #         response.status = 200
  #         output = { session_ids: TrackSession.all }
  #         JSON.pretty_generate(output)
  #       end

  #       routing.get do # GET api/v1/sessions/[session_id]
  #         session = TrackSession.where(id: session_id).first
  #         session ? JSON.pretty_generate(session) : raise('Session not found')
  #       rescue StandardError
  #         routing.halt(404, { message: 'Session not found' }.to_json)
  #       end
  #     end

  #     # this routing is to get all locations associated with a session
  #     routing.get do # GET api/v1/sessions/[session_id]/locations
  #       session = TrackSession.where(id: session_id).first

  #       session || raise('Session not found')
  #     rescue StandardError
  #       routing.halt(404, { message: 'Session not found' }.to_json)
  #     end

  #     all_locations = Location.where(session_id: session_id)
  #     all_locations ? JSON.pretty_generate(all_locations) : raise('Locations not found')
  #   rescue StandardError
  #     routing.halt(404, { message: 'Locations not found' }.to_json)
  #   end
  # end

  #     routing.post do # POST api/v1/sessions
  #       new_data = JSON.parse(routing.body.read)
  #       new_session = TrackSession.new(new_data)

  #       if new_session.save
  #         response.status = 201
  #         { message: 'Session saved', id: new_session.id }.to_json
  #       else
  #         routing.halt 400, { message: 'Could not save session' }.to_json
  #       end
  #     end
