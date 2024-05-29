# frozen_string_literal: true

require 'roda'
require_relative './app'

module Cryal
    # Web controller for Credence API
    class Api < Roda
        include Cryal
        @account_route = "api/v1/accounts"
        route('accounts') do |routing|
            routing.on String do |account_id|
                # GET /api/v1/accounts/account_id
                routing.get do
                    output = Cryal::AccountService::Account::FetchOne.call(routing, account_id)
                    response.status = 200
                    output.to_json
                end
            end

            # POST /api/v1/accounts
            routing.post do
                json = JSON.parse(routing.body.read)
                output = Cryal::GlobalActions::Account::Create.call(json)
                response.status = 201
                response['Location'] = "#{@account_route}/#{output.username}"
                { message: 'Account created', data: output }.to_json
            rescue StandardError => e
                log_and_handle_error(routing, json, e)
            end
        end
    end
end