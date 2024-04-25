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
    app.DB[:users].insert(DATA[:users].first)
    # fill the location table with the first seed
    app.DB[:locations].insert(DATA[:locations].first)
  end

  describe 'HAPPY: Test GET' do
    it 'should get all locations' do
      get 'api/v1/location'
      _(last_response.status).must_equal 200
      locations = JSON.parse(last_response.body)
      _(locations.length).must_equal 1
    end

    it 'should get a single location' do
      location_id = DATA[:locations].first
      location_id = location_id['location_id']
      get "api/v1/location/#{location_id}"
      _(last_response.status).must_equal 200
      location = JSON.parse(last_response.body)
      _(location['id']).must_equal location_id
    end

    it 'should get all locations for a user' do
      user_id = DATA[:users].first
      user_id['user_id']
      get 'api/v1/users/1/location'
      _(last_response.status).must_equal 200
      locations = JSON.parse(last_response.body)
      _(locations.length).must_equal 1
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if location is not found' do
      get 'api/v1/location/100'
      _(last_response.status).must_equal 404
    end

    it 'should return 404 if user is not found' do
      get 'api/v1/users/100/location'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY: Test POST' do
    # it 'should create a new location' do
    #   # use the second seed to create a new location
    #   post 'api/v1/location', DATA[:locations][1].to_json
    #   _(last_response.status).must_equal 201
    #   location = JSON.parse(last_response.body)
    #   _(location['id']).wont_be_nil
    # end

    it 'should create a new location for a user' do # Review this again
      user_id = DATA[:users].first
      user_id['id']
      post 'api/v1/users/1/location', DATA[:locations].first.to_json
      _(last_response.status).must_equal 201
      location = JSON.parse(last_response.body)
      _(location['data']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 404 if user is invalid' do
      post 'api/v1/users/100/location', {}.to_json
      _(last_response.status).must_equal 404
    end
  end
end
