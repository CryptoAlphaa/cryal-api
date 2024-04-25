# This is spec file for rooms model
# We want to test the API to properly interact with the rooms model
# We will test the GET and POST routes for the rooms model
# frozen_string_literal: true

require_relative 'init_spec'

describe 'Test Room Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # because room needs a foreign key of users and targets, we need to insert them first
    app.DB[:users].insert(seed_data[:users][0])
    app.DB[:targets].insert(seed_data[:targets][0])
    app.DB[:rooms].insert(seed_data[:rooms][0])
  end

  describe 'HAPPY: Test GET' do
    it 'should get all rooms' do
      get '/rooms'
      _(last_response.status).must_equal 200
      rooms = JSON.parse(last_response.body)
      _(rooms.length).must_equal 1
    end

    it 'should get a single room' do
      room_id = seed_data[:rooms].first['id']
      get "/rooms/#{room_id}"
      _(last_response.status).must_equal 200
      room = JSON.parse(last_response.body)
      _(room['id']).must_equal room_id
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if room is not found' do
      get '/rooms/100'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new room' do
      # use the second seed to create a new room
      # but first we need to insert the user and target
      app.DB[:users].insert(seed_data[:users][1])
      app.DB[:targets].insert(seed_data[:targets][1])
      post '/rooms', seed_data[:rooms][1].to_json
      _(last_response.status).must_equal 201
      room = JSON.parse(last_response.body)
      _(room['id']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 400 if data is invalid' do
      post '/rooms', {}.to_json
      _(last_response.status).must_equal 400
    end
  end
end
