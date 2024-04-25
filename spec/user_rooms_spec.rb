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
    app.DB[:users].insert(seed_data[:users][0])
    app.DB[:rooms].insert(seed_data[:rooms][0])
    app.DB[:user_rooms].insert(seed_data[:user_rooms][0])
  end

  describe 'HAPPY: Test GET' do
    it 'should get all user_rooms' do
      get '/user_rooms'
      _(last_response.status).must_equal 200
      user_rooms = JSON.parse(last_response.body)
      _(user_rooms.length).must_equal 1
    end

    it 'should get a single user_room' do
      user_room_id = seed_data[:user_rooms].first['id']
      get "/user_rooms/#{user_room_id}"
      _(last_response.status).must_equal 200
      user_room = JSON.parse(last_response.body)
      _(user_room['id']).must_equal user_room_id
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if user_room is not found' do
      get '/user_rooms/100'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new user_room' do
      # use the second seed to create a new user_room
      # but first we need to insert the user and room
      app.DB[:users].insert(seed_data[:users][1])
      app.DB[:rooms].insert(seed_data[:rooms][1])
      post '/user_rooms', seed_data[:user_rooms][1].to_json
      _(last_response.status).must_equal 201
      user_room = JSON.parse(last_response.body)
      _(user_room['id']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 400 if data is invalid' do
      post '/user_rooms', {}.to_json
      _(last_response.status).must_equal 400
    end
  end
end