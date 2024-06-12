# frozen_string_literal: true

require 'roda'
require_relative './app'

module Cryal
  # Web controller for Credence API
  class Api < Roda
    include Cryal
    @account_route = 'api/v1/accounts'
    route('accounts') do |routing|
      routing.get do
        # GET /api/v1/accounts?username=username
        routing.halt(403, UNAUTH_MSG) unless @auth_account
        account_username = routing.params['username']
        output = Cryal::AccountService::Account::FetchAccount.call(@auth_account, account_username)
        response.status = 200
        { message: 'Account data retrieved', data: output }.to_json
      rescue Cryal::AccountService::Account::FetchAccount::ForbiddenError => e
        routing.halt 404, { message: e.message }.to_json
      rescue StandardError
        routing.halt 500, { message: 'API Server Error' }.to_json
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
