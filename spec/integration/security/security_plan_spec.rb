# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Plan Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
    # to create a waypoint, we need a user, room, user_room, plan, and waypoint
  end

  describe 'SECURITY: Mass Assignment' do
    it 'should not allow post to change id' do
      data = populate_plan
      post_item = DATA[:plans][3]
      post_item[:plan_id] = 100
      account_id = data[0][:account_id]
      room_name = data[1][:room_name]
      post_item['room_name'] = room_name
      post "/api/v1/accounts/#{account_id}/plans/create_plan", post_item.to_json
      _(last_response.status).must_equal 400
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'SECURITY: SQL Injection' do
    it 'should prevent SQL injection to get index' do
      get 'api/v1/accounts/2%20or%20id%3D1/plans/1'
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'SECURITY: Non-deterministic UUIDs' do
    it 'should generate non-deterministic UUIDs' do
      data = populate_plan
      account_id = data[0][:account_id]
      room_name = data[1][:room_name]
      post_item = { plan_name: 'New Plan', plan_description: 'New Description', room_name: }
      post "/api/v1/accounts/#{account_id}/plans/create_plan", post_item.to_json
      first_plan = JSON.parse(last_response.body)['data']
      post_item = { plan_name: 'New Plan 2', plan_description: 'New Description 2', room_name: }
      post "/api/v1/accounts/#{account_id}/plans/create_plan", post_item.to_json
      second_plan = JSON.parse(last_response.body)['data']
      _(first_plan['plan_id']).wont_equal(second_plan['plan_id'])
    end
  end

  describe 'SECURITY: Encrypted Data Fields' do
    it 'should encrypt and decrypt sensitive data fields' do
      data = populate_plan
      account_id = data[0][:account_id]
      room_name = data[1][:room_name]
      post_item = { plan_name: 'New Plan 100', plan_description: 'New Description 100', room_name: }
      post "/api/v1/accounts/#{account_id}/plans/create_plan", post_item.to_json
      plans = JSON.parse(last_response.body)['data']
      _(plans['plan_description'].to_s).wont_equal(post_item['plan_description'].to_s)
    end
  end
end

def populate_plan # rubocop:disable Metrics/AbcSize
  first_user = Cryal::Account.create(DATA[:accounts][0])
  second_user = Cryal::Account.create(DATA[:accounts][1])
  room = first_user.add_room(DATA[:rooms][0])
  room_data = Cryal::Room.where(room_name: 'Meeting Room 1').first
  prepare_to_join_room = { room_id: room_data[:room_id], active: true }
  second_user.add_user_room(prepare_to_join_room)
  prepare_plan = DATA[:plans][0]
  # prepare_plan[:room_id] = room_data[:room_id]
  room.add_plan(prepare_plan)
  [second_user, room]
end
