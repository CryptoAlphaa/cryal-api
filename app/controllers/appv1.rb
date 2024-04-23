# frozen_string_literal: true

require 'roda'
require 'json'
require_relative '../models/routes'

module Cryal
  # API for a CRUD process
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Routes.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        response.status = 200
        { message: 'Welcome to Cryal API' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'routes' do
            # GET api/routes/[id]
            routing.get String do |id|
              response.status = 200
              Routes.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Route not found' }.to_json
            end

            # GET api/routes/
            routing.get do
              response.status = 200
              output = { routes_ids: Routes.all }
              JSON.pretty_generate(output)
            end

            # POST api/routes/
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_route = Routes.new(new_data)

              if new_route.save
                response.status = 201
                { message: 'Route saved', id: new_route.id }.to_json
              else
                routing.halt 400, { message: 'Could not save Route' }.to_json
              end
            end
          end
        end
        response.status = 200
        { message: 'This is the API dir' }.to_json
      end
    end
  end
end
