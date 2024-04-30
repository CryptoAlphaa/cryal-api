# frozen_string_literal: true

require 'sequel'

module Cryal
  # Room model
  class Room < Sequel::Model
    one_to_many :user_rooms
    one_to_one :user
    one_to_many :plans

    plugin :timestamps, update_on_create: true

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :room_name, :room_description_secure

    # Secure getters and setters
    def description
      SecureDB.decrypt(room_description_secure)
    end

    def description=(plaintext)
      self.room_description_secure = SecureDB.encrypt(plaintext)
    end

    def passwordHash=(password)
      self.password_hash = SecureDB.hash(password)
    end

    def to_json(*args)
      {
        room_id: room_id,
        room_name: room_name,
        room_description: description,
        created_at: created_at,
        updated_at: updated_at
      }.to_json(*args)
      
    end
  end
end
