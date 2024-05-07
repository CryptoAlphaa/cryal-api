# frozen_string_literal: true

module Cryal
  module GlobalActions
    module User
      # Create a new user
      class Create
        extend Cryal
        def self.call(json)
          final_user = Cryal::User.new(json)
          final_user.save
          final_user
        end
      end

      # Fetch all existing user
      class FetchAll
        extend Cryal
        def self.call(_routing)
          output = { data: Cryal::User.all }
          output
        end
      end
    end

    module Room
      # Fetch all existing room
      class FetchAll
        extend Cryal
        def self.call(_routing)
          output = { data: Cryal::Room.all }
          output
        end
      end

      # Fetch a specific room
      class FetchOne
        extend Cryal
        def self.call(routing, room_id)
          output = Cryal::Room.first(room_id:)
          not_found(routing, 'Room not found') if output.nil?
          output
        end
      end
    end

    module UserRooms
      # fetch all user rooms
      class FetchAll
        extend Cryal
        def self.call(_routing)
          output = { data: Cryal::User_Room.all }
          output#.t
        end
      end
    end
  end
end
