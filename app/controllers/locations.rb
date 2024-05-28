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
                    
                    account = Account.first(username: @auth_account['username'])
                    output = Cryal::AccountService::Location::FetchAll.call(routing, account.account_id)
                    response.status = 200
                    output.to_json
                end

                # POST /api/v1/locations
                routing.post do
                    p "Auth Account: #{@auth_account}"
                    account = Account.first(username: @auth_account['username'])
                    json = JSON.parse(routing.body.read)
                    p "JSON: #{json}"
                    output = Cryal::AccountService::Location::Create.call(routing, json, account.account_id)
                    response.status = 201
                    { message: 'Location saved', data: output }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, json, e)
                end
            end
        end
    end
end