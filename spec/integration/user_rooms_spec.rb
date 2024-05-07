# This spec file is used to test the user_room model
# We want to test the API to properly interact with the user_room model
# We will test the GET and POST routes for the user_room model

# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test UserRoom Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # because user_room needs a foreign key of users and rooms, we need to insert them first
    first_user = Cryal::Account.create(DATA[:accounts][0])
    second_user = Cryal::Account.create(DATA[:accounts][1])
    first_user.add_room(DATA[:rooms][0])
    room_data = Cryal::Room.where(room_name: 'Meeting Room 1').first
    prepare_to_join_room = { room_id: room_data[:room_id], active: true }
    second_user.add_user_room(prepare_to_join_room)
  end

  describe 'HAPPY: Test GET' do
    it 'should get all userrooms' do
      get 'api/v1/userrooms'
      _(last_response.status).must_equal 200
      user_rooms = JSON.parse(last_response.body)
      _(user_rooms.length).must_equal 1
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new userroom' do
      # use api/v1/accounts/account_id/joinroom/room_id to create a new user_room
      third_user = Cryal::Account.create(DATA[:accounts][2])
      room_data = Cryal::Room.where(room_name: 'Meeting Room 1').first
      account_id = third_user[:account_id]
      prepare_to_join_room = { room_id: room_data[:room_id], active: true }
      post "api/v1/accounts/#{account_id}/joinroom", prepare_to_join_room.to_json
      _(last_response.status).must_equal 201
      user_room = JSON.parse(last_response.body)
      _(user_room['data']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 404 if data is invalid' do
      post 'api/v1/accounts/100/joinroom', {}.to_json
      _(last_response.status).must_equal 404
    end
  end
end
