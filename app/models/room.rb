# frozen_string_literal: true

require 'sequel'
require_relative './password'

module Cryal
  # Room model
  class Room < Sequel::Model
    one_to_many :user_rooms, class: 'Cryal::User_Room', on_delete: :cascade
    many_to_one :account, class: 'Cryal::Account'
    one_to_many :plans, class: 'Cryal::Plan', on_delete: :cascade

    plugin :timestamps, update_on_create: true
    plugin :uuid, field: :room_id

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :room_name, :room_description, :room_password

    # Secure getters and setters
    def room_description
      SecureDB.decrypt(room_description_secure)
    end

    def room_description=(plaintext)
      self.room_description_secure = SecureDB.encrypt(plaintext)
    end

    def room_password=(new_password)
      self.room_password_hash = Cryal::Password.digest(new_password)
    end

    def room_password?(try_password)
      password = Cryal::Password.from_digest(room_password_hash)
      password.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          room_id:,
          room_name:,
          room_description:,
          created_at:,
          updated_at:
        },
        options
      )
    end
  end
end
