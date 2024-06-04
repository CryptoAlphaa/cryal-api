# frozen_string_literal: true

module Cryal
    # Methods for controllers to mixin
    module SecureRequestHelpers
      def secure_request?(routing)
        routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
      end

      def authenticated_account(headers)
        # puts "HEADERS: #{headers.inspect}\n\n\n"
        # puts "HTTP_AUTHORIZATION",headers['HTTP_AUTHORIZATION']
        # puts "Authorization", headers['Authorization']
        # puts "AUTHORIZATION", headers['AUTHORIZATION']
        return nil unless headers['Authorization']

        scheme, auth_token = headers['Authorization'].split
        # puts "scheme", scheme
        # puts "auth_token", auth_token.class
        account_payload = AuthToken.new(auth_token).payload

        puts "ACCOUNT PAYLOAD in helper: #{account_payload}"
        # account_payload
        scheme.match?(/^Bearer$/i) ? account_payload : nil
      end
    end
  end
