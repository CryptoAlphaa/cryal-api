# This spec file is used to test the location model
# We want to test the API to properly interact with the user model
# We will test the GET and POST routes for the user model

# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Location Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
    first_data = Cryal::Account.create(DATA[:accounts].first)
    first_data.add_location(DATA[:locations].first)
  end

  describe 'HAPPY: Test GET' do
    it 'should get all locations for a user' do
      account_id = Cryal::Account.create(DATA[:accounts][1])
      account_id.add_location(DATA[:locations].first)
      account_id = account_id[:account_id]
      get "api/v1/accounts/#{account_id}/locations"
      _(last_response.status).must_equal 200
      locations = JSON.parse(last_response.body)
      _(locations.length).must_equal 1
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if user not found' do
      Cryal::Account.first
      account_id = 100
      get "api/v1/accounts/#{account_id}/locations"
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new location for a user' do
      account_id = Cryal::Account.create(DATA[:accounts][1])
      account_id = account_id[:account_id]
      # use the second seed to create a new location
      post "api/v1/accounts/#{account_id}/locations", DATA[:locations][1].to_json
      _(last_response.status).must_equal 201
      location = JSON.parse(last_response.body)
      _(location['data']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 404 if user is not found' do
      post 'api/v1/accounts/100/locations', DATA[:locations][2].to_json
      _(last_response.status).must_equal 404
    end
  end
end
