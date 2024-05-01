# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test Location Model' do
  before do
    clear_db
    load_seed
    app.DB[:users].insert(DATA[:users].first)
    app.DB[:locations].insert(DATA[:locations].first)
  end

  describe 'SECURITY: Mass Assignment' do
    it 'should not allow changing location data' do
      location = Location.first(id: DATA[:locations].first[:id])
      original_data = location.data
      post "api/v1/locations/#{location.id}", { data: 'new data' }.to_json
      location.refresh
      _(location.data).must_equal original_data
    end
  end

  describe 'SECURITY: SQL Injection' do
    it 'should prevent SQL injection through query parameters' do
      get 'api/v1/location/1/2%20or%20id%3D1'
      _(last_response.status).must_equal 404
      _(app.DB[:locations].count).wont_equal 0
    end

    it 'should prevent SQL injection through POST data' do
      malicious_data = { name: "Test'; DROP TABLE locations;" }.to_json
      post 'api/v1/users/1/locations', malicious_data
      _(last_response.status).must_equal 400  # Assuming your API has validation and rejects this
      _(app.DB[:locations].count).wont_equal 0
    end
  end

  describe 'SECURITY: Unauthorized Access' do
    it 'should not allow users to access others\' locations' do
      # Insert a user with ID 2 who does not have any locations
      app.DB[:users].insert(id: 2, name: 'User 2', email: 'user2@example.com')
      # Assuming user ID 2 is not in the seed data for user ID 1's locations
      get 'api/v1/users/2/location'
      _(last_response.status).must_equal 404
    end
  end

  describe 'SECURITY: Non-Deterministic UUID' do
    it 'generates non-deterministic UUIDs for new locationsn' do
      post 'api/v1/location', { name: 'New Location' }.to_json
      location1 = JSON.parse(last_response.body)['id']
      post 'api/v1/location', { name: 'Another Location' }.to_json
      location2 = JSON.parse(last_response.body)['id']
      _(location1).wont_equal location2
    end
  end

  describe 'SECURITY: Encryption Integrity' do
    it 'ensures that encrypted fields are correctly handled' do
      # Insert a location with encrypted data
      encrypted_data = 'some encrypted data'
      app.DB[:locations].insert(id: 1, data: encrypted_data)
      # Retrieve the location
      get 'api/v1/locations/1'
      location = JSON.parse(last_response.body)
      # Check that the data is correctly decrypted
      _(location['data']).must_equal 'some decrypted data'
    end
  end

  describe 'SECURITY: Data Exposure' do
    it 'should not expose sensitive location details publicly' do
      get 'api/v1/location'
      locations = JSON.parse(last_response.body)
      locations.each do |location|
        _(location.key?('precise_coordinates')).must_equal false
      end
    end
  end
end
