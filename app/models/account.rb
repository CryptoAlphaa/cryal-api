# frozen_string_literal: true

require 'json'
require 'sequel'
require 'rbnacl'
require_relative './password'

module Cryal
  # User model
  class Account < Sequel::Model
    one_to_many :locations, class: 'Cryal::Location', on_delete: :cascade
    one_to_many :user_rooms, class: 'Cryal::User_Room', on_delete: :cascade
    one_to_many :rooms, class: 'Cryal::Room'

    plugin :timestamps, update_on_create: true
    plugin :uuid, field: :account_id

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :username, :email, :password_hash, :email_secure, :password

    def self.create_github_account(github_account)
      create(username: github_account[:username], email_secure: SecureDB.encrypt(github_account[:email]),
             password_hash: 'test')
    end

    def password=(new_password)
      self.password_hash = Cryal::Password.digest(new_password)
    end

    def password?(try_password)
      password = Cryal::Password.from_digest(password_hash)
      password.correct?(try_password)
    end

    def self.username_exist?(username)
      # encrypted_email = SecureDB.encrypt(email)
      Account.first(username:)
    end

    def email
      email_secure
    end

    def email=(plaintext)
      self.email_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(options = {})
      JSON(
        {
          username:,
          email: SecureDB.decrypt(email_secure),
          created_at:,
          updated_at:
        },
        options
      )
    end

    def to_json_all(options = {}) # rubocop: disable Metrics/MethodLength
      JSON(
        {
          account_id:,
          username:,
          email_secure:,
          password_hash:,
          created_at:,
          updated_at:
        },
        options
      )
    end
  end
end
