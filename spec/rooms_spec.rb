# This is spec file for rooms model
# We want to test the API to properly interact with the rooms model
# We will test the GET and POST routes for the rooms model
# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Room Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # because room needs a foreign key of users and targets, we need to insert them first
    app.DB[:users].insert(DATA[:users][0])
    app.DB[:targets].insert(DATA[:targets][0])
    app.DB[:rooms].insert(DATA[:rooms][0])
  end

  describe 'HAPPY: Test GET' do
    it 'should get all rooms' do
      get 'api/v1/rooms'
      _(last_response.status).must_equal 200
      rooms = JSON.parse(last_response.body)
      _(rooms.length).must_equal 1
    end

    it 'should get a single room' do
      room_id = DATA[:rooms].first
      room_id = room_id[:id]
      get "api/v1/rooms/#{room_id}"
      _(last_response.status).must_equal 200
      room = JSON.parse(last_response.body)
      _(room['id']).must_equal room_id
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if room is not found' do
      get 'api/v1/rooms/100'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new room by a user' do
      # use the second seed to create a new room
      # but first we need to insert the user and target
      app.DB[:users].insert(DATA[:users][1])
      app.DB[:targets].insert(DATA[:targets][1])
      post 'api/v1/users/2/createroom', DATA[:rooms][1].to_json
      _(last_response.status).must_equal 201
      room = JSON.parse(last_response.body)
      _(room['data']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 404 if data is invalid' do
      post 'api/v1/users/2/createroom', {}.to_json
      _(last_response.status).must_equal 404
    end
  end
end
