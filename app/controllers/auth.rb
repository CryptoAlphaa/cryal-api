# frozen_string_literal: true

require 'roda'
require_relative './app'

module Cryal
  # Web controller for Credence API
  class Api < Roda
    include Cryal
    route('auth') do |routing|
      # POST /api/v1/auth/register
      routing.is 'register' do
        routing.post do
          json = JSON.parse(routing.body.read, symbolize_names: true)
          register = VerifyRegistration.new(json).call
          # register = Cryal::Register.call(routing, json)
          response.status = 202
          register.to_json
        end
      end

      # POST /api/v1/auth/authentication
      routing.is 'authentication' do
        routing.post do
          json = JSON.parse(routing.body.read)
          authenticate = Authenticate.call(routing, json)
          response.status = 200
          authenticate.to_json
        end
      end

      routing.is 'sso' do
        routing.post do
          auth_request = JSON.parse(request.body.read, symbolize_names: true)
          auth_account = AuthViaSSO::AuthorizeSso.new.call(auth_request[:access_token])
          { data: auth_account }.to_json
        rescue StandardError => error
          puts "FAILED to validate Github account: #{error.inspect}"
          puts error.backtrace
          routing.halt 400          
        end
      end
    end
  end
end