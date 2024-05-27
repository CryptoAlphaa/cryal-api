# frozen_string_literal: true

module Cryal
    # Methods for controllers to mixin
    module SecureRequestHelpers
      def secure_request?(routing)
        routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
      end
  
      def authenticated_account(headers)
        # p "HEADERS: #{headers.inspect}\n\n\n"
        return nil unless headers['AUTHORIZATION']
  
        scheme, auth_token = headers['AUTHORIZATION'].split
        account_payload = AuthToken.new(auth_token).payload
        # p "ACCOUNT PAYLOAD in helper: #{account_payload}"
        # account_payload
        scheme.match?(/^Bearer$/i) ? account_payload : nil
      end
    end
  end