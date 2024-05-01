# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test Rooms Model' do
  before do
    clear_db
    load_seed
    # because room needs a foreign key of users and targets, we need to insert them first
    app.DB[:users].insert(DATA[:users][0])
    app.DB[:targets].insert(DATA[:targets][0])
    app.DB[:rooms].insert(DATA[:rooms][0])
  end

  describe 'SECURITY: Mass Assignment' do
    # IDK
  end

  describe 'SECURITY: SQL Injection' do
    it 'should prevent SQL injection in room queries' do
      get 'api/v1/rooms/1%20or%20id%3D1'
      _(last_response.status).must_equal 404
      # Verify the rooms table still exists and has data
      _(app.DB[:rooms].count).wont_equal 0
    end
  end

  describe 'SECURITY: Non-Deterministic UUIDs' do
    it 'generates non-deterministic UUIDs for new rooms' do
      post 'api/v1/users/1/createroom', { name: 'Room A' }.to_json
      room1_id = JSON.parse(last_response.body)['data']['id']
      post 'api/v1/users/1/createroom', { name: 'Room B' }.to_json
      room2_id = JSON.parse(last_response.body)['data']['id']
      _(room1_id).wont_equal room2_id
    end
  end
 
  describe 'SECURITY: Encryption of Sensitive Data' do
    it 'ensures sensitive room data is encrypted' do
      # Assuming that the room description should be encrypted
      post 'api/v1/users/1/createroom', { description: 'Secret Room' }.to_json
      room = app.DB[:rooms].where(id: JSON.parse(last_response.body)['data']['id']).first
      _(room[:description]).wont_match /Secret Room/  # Check that the description isn't stored in plain text
    end
  end

  describe 'SECURITY: Data Exposure' do
    it 'should not expose sensitive room details publicly' do
      get 'api/v1/rooms'
      rooms = JSON.parse(last_response.body)
      rooms.each do |room|
        _(room.key?('precise_coordinates')).must_equal false
      end
    end
  end
end
