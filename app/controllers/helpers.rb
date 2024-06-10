# frozen_string_literal: true

module Cryal
  # Methods for controllers to mixin
  module SecureRequestHelpers
    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    def authenticated_account(headers)
      # puts "HEADERS: #{headers.inspect}\n\n\n"
      return nil unless headers['Authorization']

      scheme, auth_token = headers['Authorization'].split
      account_payload = AuthToken.new(auth_token).payload
      scheme.match?(/^Bearer$/i) ? account_payload : nil
      Account.first(username: account_payload['username'])
    end
  end
end
