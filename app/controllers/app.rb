# frozen_string_literal: true

require 'sequel'
require 'roda'
require 'json'
require_relative './helpers'

# Cryal Module
module Cryal
  # Class for designing the API
  class Api < Roda
    plugin :environments
    plugin :halt
    plugin :json
    plugin :multi_route
    plugin :request_headers
    plugin :all_verbs

    include SecureRequestHelpers
    include Cryal

    UNAUTH_MSG = { message: 'Unauthorized Request' }.to_json

    route do |routing|
      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        not_found(routing, 'TLS/SSL Required', 403)

      begin
        @auth = authorization(routing.headers)
        @auth_account = @auth[:account] if @auth

        # @auth_account = authenticated_account(routing.headers)
      rescue AuthToken::InvalidTokenError
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      end

      routing.root do
        response.status = 200
        { message: 'Welcome to Cryal APIs' }.to_json
      end

      routing.on 'api/v1' do
        @api_root = 'api/v1'
        # routing.halt 403, { message: 'Forbidden!' }.to_json unless @auth_account
        routing.multi_route
      end
    end
  end

  #=======================================================================================================
  # FUNCTIONS TO HANDLE ERROR
  # DO NOT DELETE
  #=======================================================================================================

  def log_and_handle_error(routing, json, err)
    if err.is_a?(Sequel::MassAssignmentRestriction)
      Api.logger.warn "Mass Assignment: #{json.keys}"
      routing.halt 400, { message: 'Mass Assignment Error' }.to_json
    else
      Api.logger.error "Error: #{err.message}"
      routing.halt 500, { message: 'Internal Server Error' }.to_json
    end
  end

  def not_found(routing, message, err = 404)
    routing.halt err, { message: }.to_json
  end
end
