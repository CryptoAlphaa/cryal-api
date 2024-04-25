# frozen_string_literal: true

require 'sequel'

module Cryal
  # User model
  class User < Sequel::Model
    one_to_many :locations
    one_to_many :user_room
    one_to_one :room

    def to_json(*args)
      {
        user_id:,
        username:,
        email:,
        password_hash:
      }.to_json(*args)
    end
  end
end
