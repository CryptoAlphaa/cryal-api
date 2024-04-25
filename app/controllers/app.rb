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
              routing.on 'createroom' do
                #post api/v1/users/[id]/createroom
                routing.post do
                  new_data = JSON.parse(routing.body.read)
                  new_data['user_id'] = user_id.to_i
                  new_target = Room.new(new_data)
                  raise('Could not save room') unless new_target.save
                  response.status = 201
                  { message: 'room saved', data: new_target }.to_json

                rescue StandardError => e
                  routing.halt 400, { message: 'DB Error', error: e }.to_json
                end
              end

              routing.on 'joinroom' do
                #post api/v1/users/[id]/joinroom
                routing.post do
                  new_data = JSON.parse(routing.body.read)
                  new_data['user_id'] = user_id.to_i
                  new_data['active'] = true
                  new_target = User_Room.new(new_data)

                  raise('Could Join Room') unless new_target.save
                  response.status = 201
                  { message: 'Room Joinned Succesfully', data: new_target }.to_json
                rescue StandardError => e
                  routing.halt 400, { message: 'DB Error', error: e }.to_json
                end
              end

              routing.on 'location' do
                #get api/vi/users/[id]/location
                routing.get do
                  output = { data: User.first(user_id: user_id).locations }
                  JSON.pretty_generate(output)
                rescue StandardError => e
                  routing.halt 400, { message: 'DB Error', error: e }.to_json
                end

                #post api/vi/users/[id]/location
                routing.post do
                  new_data = JSON.parse(routing.body.read)
                  user = User.first(user_id: user_id)
                  new_loc = user.add_location(new_data)
                  if new_loc
                    response.status = 201
                    { message: 'Location saved', data: new_loc }.to_json
                  else
                    routing.halt 400, 'Could not save document'
                  end

                rescue StandardError => e
                  routing.halt 400, { message: 'DB Error', error: e }.to_json
                end
              end

              #get api/v1/users/[id]
              routing.get do
                output = User.first(user_id: user_id)
                response.status = 200
                output.to_json
              rescue StandardError => e
                routing.halt 404, { message: 'Users not found', error: e }.to_json
              end
            end

            #get api/v1/users
            routing.get do
              output = { data: User.all }
              JSON.pretty_generate(output)
            rescue StandardError => e
              routing.halt 404, { message: 'something wrong plis fix get users', errorL: e}.to_json
            end

            #post api/v1/users
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_user = User.new(new_data)
              raise('Could not save User') unless new_user.save

              response.status = 201
              { message: 'User saved', data: new_user }.to_json
            rescue StandardError => e
              routing.halt 400, { message: 'Can\'t load any users', error: e }.to_json
            end
          end
          response.status = 200
          { message: 'Welcome to Cryal api/v1' }.to_json

          routing.on 'rooms' do
            #get api/v1/rooms
            routing.get do
              output = { data: Room.all }
              JSON.pretty_generate(output)
            rescue StandardError => e
              routing.halt 404, { message: 'something wrong plis fix get rooms', errorL: e}.to_json
            end
          end

          routing.on 'userroom' do
            #get api/v1/userroom
            routing.get do
              output = { data: User_Room.all }
              JSON.pretty_generate(output)
            rescue StandardError => e
              routing.halt 404, { message: 'something wrong plis fix get rooms', errorL: e}.to_json
            end
          end

          routing.on 'targets' do
            #get api/v1/targets
            routing.get do
              output = { data: Target.all }
              JSON.pretty_generate(output)
            rescue StandardError => e
              routing.halt 404, { message: 'something wrong plis fix get target', errorL: e}.to_json
            end

            #post api/v1/targets
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_target = Target.new(new_data)
              raise('Could not save Target') unless new_target.save
              response.status = 201
              { message: 'Target saved', data: new_target }.to_json
            rescue StandardError => e
              routing.halt 400, { message: 'Can\'t load any Target', error: e }.to_json
            end
          end
        end
        response.status = 200
        { message: 'Welcome to Cryal api' }.to_json
      end
    end
  end
end
