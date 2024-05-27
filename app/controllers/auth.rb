# frozen_string_literal: true

require 'roda'
require_relative './app'

module Cryal
  # Web controller for Credence API
    class Api < Roda
        include Cryal
        route('auth') do |routing|
            # POST /api/v1/auth/register
            routing.on 'register' do
                routing.post do
                    json = JSON.parse(routing.body.read)
                    register = Cryal::Register.call(routing, json)
                    response.status = 201
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