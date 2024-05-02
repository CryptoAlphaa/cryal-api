# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test UserRoom Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # because user_room needs a foreign key of users and rooms, we need to insert them first
  end

  describe 'SECURITY: Test Authorization' do
    it 'should prevent unauthorized users from joining a room' do
      data = Populate()
      room_id = data[1][:room_id]
      packet = { room_id: room_id, active: true }
      post 'api/v1/users/100/joinroom', packet.to_json
      _(last_response.status).must_equal 404
    end
  end

  describe 'SECURITY: Mass Assignment' do
    it 'should not allow post to change id' do
      data = Populate()
      user_id = data[0][:user_id]
      room_name = data[1][:room_name]
      post_item = { room_id: 100, active: true }
      post "/api/v1/users/#{user_id}/joinroom", post_item.to_json
      _(last_response.status).must_equal 500
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'SECURITY: SQL Injection' do
    it 'should prevent SQL injection to get index' do
      get 'api/v1/users/2%20or%20id%3D1/joinroom/1'
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end
end

def Populate
  first_user = Cryal::User.create(DATA[:users][0])
  second_user = Cryal::User.create(DATA[:users][1])
  room = first_user.add_room(DATA[:rooms][0])
  room_data = Cryal::Room.where(room_name: 'Meeting Room 1').first
  prepare_to_join_room = { room_id: room_data[:room_id], active: true }
  user_room = second_user.add_user_room(prepare_to_join_room)
  return second_user, room
end