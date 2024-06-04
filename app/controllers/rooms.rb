# frozen_string_literal: true

require 'roda'
require_relative './app'

module Cryal
  # Web controller for Credence API
    class Api < Roda
        include Cryal
        route('rooms') do |routing|
            # make three routing, get all rooms associated, create room, join room
            # GET /api/v1/rooms
            routing.get do
                not_found(routing, 'Not Authorized!') if @auth_account.nil?
                account = Account.first(username: @auth_account['username'])
                output = Cryal::AccountService::Room::FetchAll.call(routing, account.account_id)
                not_found(routing, 'DB Error') if output.nil?
                response.status = 200
                { message: 'Success', data: output }.to_json
            end

            # POST /api/v1/rooms/createroom
            routing.on 'createroom' do
                routing.post do
                    account = Account.first(username: @auth_account['username'])
                    json = JSON.parse(routing.body.read)
                    output = Cryal::AccountService::Room::Create.call(routing, json, account.account_id)
                    response.status = 201
                    { message: 'Room created', data: output }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, json, e)
                end
            end

            # POST /api/v1/rooms/joinroom
            routing.on 'joinroom' do
                routing.post do
                    account = Account.first(username: @auth_account['username'])
                    json = JSON.parse(routing.body.read)
                    output = Cryal::AccountService::Room::Join.call(routing, json, account.account_id)
                    response.status = 201
                    { message: 'Room Join Successfully', data: output }.to_json
                rescue StandardError => e
                    log_and_handle_error(routing, json, e)
                end
            end

            # GET /api/v1/rooms/[roomid]
            routing.on String do |roomid|
                routing.get do
                    account = Account.first(username: @auth_account['username'])
                    puts account
                    json = JSON.parse(routing.body.read)
                    puts json
                    output = Cryal::AccountService::Room::FetchOne.call(routing, room_id, account)

                    output
                end
            end
        end
    end
end
