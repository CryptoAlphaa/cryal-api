require 'sequel'

module Cryal
    class Room < Sequel::Model
        many_to_one :target
        one_to_many :user_room
        one_to_one :user

        def to_json(*args)
            {
                room_id: room_id,
                target_id: target_id,
                user_id: user_id,
                room_name: room_name,
                room_password: room_password,
                timestamp: timestamp
            }.to_json(*args)
        end
    end
end
