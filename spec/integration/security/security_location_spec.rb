# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test Location Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
  end

  describe 'SECURITY: Mass Assignment' do
    it 'should not allow changing location data' do
      user = DATA[:accounts][1]
      post 'api/v1/accounts', user.to_json
      user = JSON.parse(last_response.body)['data']

      locs = DATA[:locations][1]
      post "api/v1/accounts/#{user['account_id']}/locations", locs.to_json
      location = JSON.parse(last_response.body)['data']
      post "api/v1/accounts/#{user['account_id']}/locations/#{location['location_id']}", { location_id: 2 }.to_json
      _(last_response.status).must_equal 400
    end
  end

  describe 'SECURITY: SQL Injection' do
    it 'should prevent SQL injection through query parameters' do
      get 'api/v1/accounts/2%20or%20id%3D1/locations'
      _(last_response.status).must_equal 404
      _(app.DB[:locations].count).wont_equal 2
    end

    it 'should prevent SQL injection through POST data' do
      malicious_data = { name: "Test'; DROP TABLE locations;" }.to_json
      post 'api/v1/accounts/1/locations', malicious_data
      _(last_response.status).must_equal 404 # Assuming your API has validation and rejects this
    end
  end

  describe 'SECURITY: Non-Deterministic UUID' do
    it 'generates non-deterministic UUIDs for new locationsn' do
      user = DATA[:accounts][1]
      post 'api/v1/accounts', user.to_json
      user = JSON.parse(last_response.body)['data']

      locs = DATA[:locations][1]
      post "api/v1/accounts/#{user['account_id']}/locations", locs.to_json
      location1 = JSON.parse(last_response.body)['data']

      locs = DATA[:locations][2]
      post "api/v1/accounts/#{user['account_id']}/locations", locs.to_json
      location2 = JSON.parse(last_response.body)['data']

      _(location1['location_id']).wont_equal location2['location_id']
    end
  end

  describe 'SECURITY: Encryption Integrity' do
    it 'ensures that encrypted fields are correctly handled' do
      user = DATA[:accounts][1]
      locs = DATA[:locations][1]
      post 'api/v1/accounts', user.to_json
      user = JSON.parse(last_response.body)['data']
      post "api/v1/accounts/#{user['account_id']}/locations", locs.to_json
      get "api/v1/accounts/#{user['account_id']}/locations"
      loc = JSON.parse(last_response.body)
      loc = loc[0]
      _(loc['cur_lat_secure']).wont_match locs['latitude']
    end
  end

  describe 'SECURITY: Data Exposure' do
    it 'should not expose sensitive location details publicly' do
      user = DATA[:accounts][1]
      locs = DATA[:locations][1]
      post 'api/v1/accounts', user.to_json
      user = JSON.parse(last_response.body)['data']
      post "api/v1/accounts/#{user['account_id']}/locations", locs.to_json
      get "api/v1/accounts/#{user['account_id']}/locations"
      loc = JSON.parse(last_response.body)
      loc = loc[0]
      _(loc['cur_lat_secure']).wont_match locs['latitude']
    end
  end
end
