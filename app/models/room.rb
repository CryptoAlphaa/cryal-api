# frozen_string_literal: true

require 'sequel'

module Cryal
  # Room model
  class Room < Sequel::Model
    many_to_one :target
    one_to_many :user_room
    one_to_one :user

    def to_json(*args)
      {
        room_id:,
        target_id:,
        user_id:,
        room_name:,
        room_password:,
        timestamp:
      }.to_json(*args)
    end
  end
end
