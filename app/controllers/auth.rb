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
                    puts "masuk"
                    json = JSON.parse(routing.body.read, symbolize_names: true)
                    puts json
                    register = VerifyRegistration.new(json).call
                    puts "email sent"
                    # register = Cryal::Register.call(routing, json)
                    response.status = 202
                    register.to_json
                end
            end

            # POST /api/v1/auth/authentication
            routing.is 'authentication' do
                routing.post do
                    json = JSON.parse(routing.body.read)
                    authenticate = Cryal::Authenticate.call(routing, json)
                    response.status = 200
                    authenticate.to_json
                end
            end
        end
    end
end
