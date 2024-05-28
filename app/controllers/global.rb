# frozen_string_literal: true

require 'roda'
require_relative './app'

# routing.on 'rooms' do
#     routing.on String do |room_id|
#       routing.is do
#         # GET /api/v1/rooms/[room_id]
#         routing.get do
#           output = Cryal::GlobalActions::Room::FetchOne.call(routing, room_id)
#           response.status = 200
#           output.to_json
#           # global_fetch_room(routing, room_id)
#         end
#       end
#     end
#     # GET /api/v1/rooms DONEE
#     routing.get do
#       output = Cryal::GlobalActions::Room::FetchAll.call(routing)
#       response.status = 200
#       output.to_json
#       # global_fetch_room_all(routing)
#     end
#   end

#   routing.on 'userrooms' do
#     # GET /api/v1/userrooms DONE
#     routing.get do
#       output = Cryal::GlobalActions::UserRooms::FetchAll.call(routing)
#       response.status = 200
#       output.to_json
#     end

# Cryal Module
module Cryal
  # Class for Global API
  class Api < Roda # rubocop:disable Metrics/ClassLength
    route('global') do |routing|
        # GET /api/v1/global/rooms
        routing.on 'rooms' do
            routing.get do
            output = Cryal::GlobalActions::Room::FetchAll.call(routing)
            response.status = 200
            output.to_json
            end
        end
    
        # GET /api/v1/global/rooms/[room_id]
        routing.on 'rooms', String do |room_id|
            routing.get do
            output = Cryal::GlobalActions::Room::FetchOne.call(routing, room_id)
            response.status = 200
            output.to_json
            end
        end
    
        # GET /api/v1/global/userrooms
        routing.on 'userrooms' do
            routing.get do
            output = Cryal::GlobalActions::UserRooms::FetchAll.call(routing)
            response.status = 200
            output.to_json
            end
        end
    end
end
end