# frozen_string_literal: true

require 'roda'
require_relative './app'

module Cryal
  # Web controller for Credence API
    class Api < Roda
        include Cryal
        route('locations') do |routing|
            # GET /api/v1/locations
            routing.is do
                routing.get do
                    # Read account_id from query string
                    output = Cryal::AccountService::Location::FetchAll.call(requestor: @auth_account)
                    response.status = 200
                    output.to_json
                end

                # POST /api/v1/locations
                routing.post do
    
                    json = JSON.parse(routing.body.read)
                    output = Cryal::AccountService::Location::Create.call(routing, json, @auth_account)
                    response.status = 201
                    { message: 'Location saved', data: output }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, json, e)
                end
            end
        end
    end
end