# frozen_string_literal: true

require 'json'
require 'sequel'
require 'rbnacl'
require_relative './password'

module Cryal
  # User model
  class User < Sequel::Model
    one_to_many :locations, class: 'Cryal::Location', on_delete: :cascade
    one_to_many :user_rooms, class: 'Cryal::User_Room', on_delete: :cascade
    one_to_many :rooms, class: 'Cryal::Room'

    plugin :timestamps, update_on_create: true
    plugin :uuid, field: :user_id

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    def password=(new_password)
      self.password_hash = Cryal::Password.digest(new_password)
    end

    def password?(try_password)
      password = Cryal::Password.from_digest(password_digest)
      password.correct?(try_password)
    end

    def email
      email_secure
    end

    def email=(plaintext)
      self.email_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(*args)
      {
        user_id:,
        username:,
        created_at:,
        updated_at:
      }.to_json(*args)
    end
  end
end
