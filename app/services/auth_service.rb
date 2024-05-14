# frozen_string_literal: true

module Cryal
  # Authenticate Module
  module Authenticate
    @err_message = 'User or Password not found'
    extend Cryal
    def self.call(routing, json) # rubocop:disable Metrics/AbcSize
      user = Cryal::Account.first(username: json['username']) # user existed
      # raise error if user not found
      not_found(routing, @err_message, 403) if user.nil?
      # password
      jsonify = JSON.parse(user.password_hash)
      salt = Base64.strict_decode64(jsonify['salt'])
      checksum = jsonify['hash']
      extend KeyStretch
      check = Base64.strict_encode64(password_hash(salt, json['password']))
      not_found(routing, @err_message, 403) unless check == checksum
      { message: "Welcome back to NaviTogether, #{json['username']}!", data: user.to_json }
    end
  end
end
