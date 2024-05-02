# This spec file is used to test the waypoints model
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Waypoints Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
  end

  describe 'HAPPY: Test GET' do
    it 'should get all waypoints for a plan' do
      user, plan = populate
      # make one waypoint
      plan.add_waypoint(DATA[:waypoints][0])
      user_id = user[:user_id]
      get "api/v1/users/#{user_id}/plans/#{plan[:plan_id]}/waypoints"
      _(last_response.status).must_equal 200
      waypoints = JSON.parse(last_response.body)
      _(waypoints.length).must_equal 1
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if plan not found' do
      user, = populate
      user_id = user[:user_id]
      get "api/v1/users/#{user_id}/plans/100/waypoints"
      _(last_response.status).must_equal 404
    end

    it 'should return 404 if user not found' do
      get 'api/v1/users/100/plans/100/waypoints'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new waypoint for a plan' do
      user, plan = populate
      user_id = user[:user_id]
      plan_id = plan[:plan_id]
      post "api/v1/users/#{user_id}/plans/#{plan_id}/waypoints", DATA[:waypoints][1].to_json
      _(last_response.status).must_equal 201
      waypoint = JSON.parse(last_response.body)['data']
      _(waypoint['waypoint_id']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 404 if plan is not found' do
      user, = populate
      user_id = user[:user_id]
      post "api/v1/users/#{user_id}/plans/100/waypoints", DATA[:waypoints][1].to_json
      _(last_response.status).must_equal 404
    end

    it 'should return 404 if user is not found' do
      post 'api/v1/users/100/plans/100/waypoints', DATA[:waypoints][1].to_json
      _(last_response.status).must_equal 404
    end
  end
end

def populate
  first_user = Cryal::User.create(DATA[:users][0])
  second_user = Cryal::User.create(DATA[:users][1])
  room = first_user.add_room(DATA[:rooms][0])
  room_data = Cryal::Room.where(room_name: 'Meeting Room 1').first
  second_user.add_user_room({ room_id: room_data[:room_id], active: true })
  plan = room.add_plan(DATA[:plans][0])
  [second_user, plan]
end
