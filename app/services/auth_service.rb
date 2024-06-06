# frozen_string_literal: true

module Cryal
  # Authenticate Module
  module Authenticate
    @err_message = 'User or Password not found'
    extend Cryal
    def self.call(routing, json) # rubocop:disable Metrics/AbcSize
      account = Cryal::Account.first(username: json['username']) # user existed
      # raise error if user not found
      not_found(routing, @err_message, 403) if account.nil?
      # password
      jsonify = JSON.parse(account.password_hash)
      salt = Base64.strict_decode64(jsonify['salt'])
      checksum = jsonify['hash']
      extend KeyStretch
      check = Base64.strict_encode64(password_hash(salt, json['password']))
      not_found(routing, @err_message, 403) unless check == checksum
      account_and_token(account)
    end

    def self.account_and_token(account)
      {
        type: 'authenticated_account',
        attributes: {
          account:,
          auth_token: AuthToken.create(account)
        }
      }
    end

  end
end
