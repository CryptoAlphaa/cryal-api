# frozen_string_literal: true

require 'roda'
require_relative './app'

module Cryal
  # Web controller for Credence API
  class Api < Roda
    include Cryal
    route('auth') do |routing|
      begin
        @request_data = SignedRequest.new(Api.config).parse(request.body.read)
      rescue SignedRequest::VerificationError
        routing.halt '403', { message: 'Must sign request' }.to_json
      end

      # POST /api/v1/auth/register
      routing.is 'register' do
        routing.post do
          register = VerifyRegistration.new(@request_data).call
          response.status = 202
          register.to_json
        end
      end

      # POST /api/v1/auth/authentication
      routing.is 'authentication' do
        routing.post do
          authenticate = Authenticate.call(routing, @request_data)
          response.status = 200
          authenticate.to_json
        end
      end

      routing.is 'sso' do
        routing.post do
          auth_request = @request_data
          auth_account = AuthViaSSO::AuthorizeSso.new.call(auth_request[:access_token])
          { data: auth_account }.to_json
        rescue StandardError => e
          puts "FAILED to validate Github account: #{e.inspect}"
          puts e.backtrace
          routing.halt 400
        end
      end
    end
  end
end
