# frozen_string_literal: true

require 'json'
require 'sequel'

module Cryal
  # User model
  class User < Sequel::Model
    one_to_many :locations
    one_to_many :user_room
    one_to_one :room

    plugin :timestamps, update_on_create: true
    plugin :uuid, field: :user_id
    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :username, :email

    def password=(password)
      self.password_hash = SecureDB.hash(password)
    end

    def email=(email)
      self.email = SecureDB.encrypt(email)
    end

    def email
      SecureDB.decrypt(email)
    end

    def to_json(*args)
      {
        user_id: user_id,
        username: username,
        email: email,
        created_at: created_at,
        updated_at: updated_at
      }.to_json(*args)
    end
  end
end