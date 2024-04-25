# This spec file is used to test the location model
# We want to test the API to properly interact with the user model
# We will test the GET and POST routes for the user model

# frozen_string_literal: true

require_relative 'init_spec'

describe 'Test Location Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
    # because location has a foreign key, we need to insert a user first
    app.DB[:users].insert(seed_data[:users].first)
    # fill the location table with the first seed
    app.DB[:locations].insert(seed_data[:locations].first)
  end

  describe 'HAPPY: Test GET' do
    it 'should get all locations' do
      get '/locations'
      _(last_response.status).must_equal 200
      locations = JSON.parse(last_response.body)
      _(locations.length).must_equal 1
    end

    it 'should get a single location' do
      location_id = seed_data[:locations].first['id']
      get "/locations/#{location_id}"
      _(last_response.status).must_equal 200
      location = JSON.parse(last_response.body)
      _(location['id']).must_equal location_id
    end

    it 'should get all locations for a user' do
      user_id = seed_data[:users].first['id']
      get "/users/#{user_id}/locations"
      _(last_response.status).must_equal 200
      locations = JSON.parse(last_response.body)
      _(locations.length).must_equal 1
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if location is not found' do
      get '/locations/100'
      _(last_response.status).must_equal 404
    end

    it 'should return 404 if user is not found' do
      get '/users/100/locations'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new location' do
      # use the second seed to create a new location
      post '/locations', seed_data[:locations][1].to_json
      _(last_response.status).must_equal 201
      location = JSON.parse(last_response.body)
      _(location['id']).wont_be_nil
    end

    it 'should create a new location for a user' do # Review this again
      user_id = seed_data[:users].first['id']
      post "/users/#{user_id}/locations", seed_data[:locations][1].to_json
      _(last_response.status).must_equal 201
      location = JSON.parse(last_response.body)
      _(location['id']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 400 if data is invalid' do
      post '/locations', {}.to_json
      _(last_response.status).must_equal 400
    end

    it 'should return 400 if user is invalid' do
      post '/users/100/locations', {}.to_json
      _(last_response.status).must_equal 400
    end
  end
end
