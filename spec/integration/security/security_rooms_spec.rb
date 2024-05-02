# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test Rooms Model' do
  before do
    clear_db
    load_seed
    # because room needs a foreign key of users and targets, we need to insert them first
  end

  describe 'SECURITY: Mass Assignment' do
    it 'should not allow post to change id' do
      data = Populate()
      user_id = data[0][:user_id]
      post_item = DATA[:rooms][1]
      post_item[:room_id] = 100
      post "/api/v1/users/#{user_id}/createroom", post_item.to_json
      _(last_response.status).must_equal 400
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'SECURITY: SQL Injection' do
    it 'should prevent SQL injection in room queries' do
      get 'api/v1/rooms/1%20or%20id%3D1'
      _(last_response.status).must_equal 404
    end
  end

  describe 'SECURITY: Non-Deterministic UUIDs' do
    it 'generates non-deterministic UUIDs for new rooms' do
      data = Populate()
      user_id = data[0][:user_id]
      post "api/v1/users/#{user_id}/createroom", DATA[:rooms][1].to_json
      room1_id = JSON.parse(last_response.body)['data']['room_id']
      post "api/v1/users/#{user_id}/createroom", DATA[:rooms][2].to_json
      room2_id = JSON.parse(last_response.body)['data']['room_id']
      _(room1_id).wont_equal room2_id
    end
  end
 
  describe 'SECURITY: Encryption of Sensitive Data' do
    it 'ensures sensitive room data is encrypted' do
      # Assuming that the room description should be encrypted
      data = Populate()
      user_id = data[0][:user_id]
      room_description = DATA[:rooms][2][:room_description]
      post "api/v1/users/#{user_id}/createroom", DATA[:rooms][2].to_json
      room = JSON.parse(last_response.body)['data']
      _(room[:room_description]).wont_match room_description
    end
  end

  describe 'SECURITY: Data Exposure' do
    it 'should not expose sensitive room details publicly' do
      data = Populate()
      get 'api/v1/rooms'
      rooms = JSON.parse(last_response.body)['data']
      rooms.each do |room|
        _(room.key?('password_hash')).must_equal false
      end
    end
  end
end

def Populate()
  first_user = Cryal::User.create(DATA[:users][0])
  room = first_user.add_room(DATA[:rooms][0])
  return first_user, room
end