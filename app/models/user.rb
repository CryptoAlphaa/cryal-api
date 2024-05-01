# frozen_string_literal: true

require 'json'
require 'sequel'
require 'rbnacl'

module Cryal
  # User model
  class User < Sequel::Model
    one_to_many :locations
    one_to_many :user_rooms, class: 'Cryal::User_Room'
    one_to_many :rooms

    plugin :timestamps, update_on_create: true
    plugin :uuid, field: :user_id

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    def password=(plaintext)
      self.password_hash = SecureDB.hash(plaintext)
    end

    def password
      self.password_hash
    end

    def email
      self.email_secure
    end

    def email=(plaintext)
      self.email_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(*args)
      {
        user_id: user_id,
        username: username,
        email_secure: email_secure,
        created_at: created_at,
        updated_at: updated_at,
        password_hash: password_hash
      }.to_json(*args)
    end
  end
end
