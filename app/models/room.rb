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
                room_name: room_name,
                room_password: room_password,
                created_time: created_time
            }.to_json(*args)
        end
    end
end
