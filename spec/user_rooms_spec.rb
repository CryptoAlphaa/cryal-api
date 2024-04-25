# This spec file is used to test the user_room model
# We want to test the API to properly interact with the user_room model
# We will test the GET and POST routes for the user_room model

# frozen_string_literal: true

require_relative 'init_spec'

describe 'Test UserRoom Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # because user_room needs a foreign key of users and rooms, we need to insert them first
    app.DB[:users].insert(DATA[:users][0])
    app.DB[:targets].insert(DATA[:targets][0])
    app.DB[:rooms].insert(DATA[:rooms][0])
    app.DB[:user_rooms].insert(DATA[:user_rooms][0])
  end

  describe 'HAPPY: Test GET' do
    it 'should get all user_rooms' do
      get 'api/v1/user_rooms'
      _(last_response.status).must_equal 200
      user_rooms = JSON.parse(last_response.body)
      _(user_rooms.length).must_equal 1
    end

    it 'should get a single user_room' do
      user_room_id = DATA[:user_rooms].first
      user_room_id = user_room_id[:id]
      get "api/v1/user_rooms/#{user_room_id}"
      _(last_response.status).must_equal 200
      user_room = JSON.parse(last_response.body)
      _(user_room['id']).must_equal user_room_id
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if user_room is not found' do
      get 'api/v1/user_rooms/100'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new user_room' do
      # use api/v1/users/user_id/joinroom/room_id to create a new user_room
      post 'api/v1/users/1/joinroom', DATA[:user_rooms][1].to_json
      _(last_response.status).must_equal 201
      user_room = JSON.parse(last_response.body)
      _(user_room['data']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 404 if data is invalid' do
      post 'api/v1/users/100/joinroom', {}.to_json
      _(last_response.status).must_equal 404
    end
  end
end
