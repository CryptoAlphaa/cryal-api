# frozen_string_literal: true

require 'roda'
require_relative './app'

# Cryal Module
module Cryal
  # Class for Global API
  class Api < Roda
    route('global') do |routing|
      # GET /api/v1/global/rooms
      routing.on 'rooms' do
        routing.get do
          output = GlobalActions::Room::FetchAll.call(routing)
          response.status = 200
          output.to_json
        end
      end

      # GET /api/v1/global/rooms/[room_id]
      routing.on 'rooms', String do |room_id|
        routing.get do
          output = GlobalActions::Room::FetchOne.call(routing, room_id)
          response.status = 200
          output.to_json
        end
      end

      # GET /api/v1/global/userrooms
      routing.on 'userrooms' do
        routing.get do
          output = GlobalActions::UserRooms::FetchAll.call(routing)
          response.status = 200
          output.to_json
        end
      end
    end
  end
end
