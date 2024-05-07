# frozen_string_literal: true

# This spec file is to test user model without the need to connect using the API
require_relative '../spec_helper'

describe 'Waypoints Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
  end
  describe 'HAPPY: Waypoints Model' do
    it 'should get all users and retrieve the correct information' do
      _, plan = prepare_sample_data
      original_waypoint = DATA[:waypoints][0]
      waypoint = plan.add_waypoint(original_waypoint)
      _(waypoint[:waypoint_name]).must_equal original_waypoint['waypoint_name']
      _(waypoint[:waypoint_lat_secure]).wont_be_nil
    end
  end

  describe 'SAD: Waypoints Model' do
    it 'should return nil if waypoint is not found' do
      _, plan = prepare_sample_data
      waypoint = plan.add_waypoint(DATA[:waypoints][0])
      waypoint[:waypoint_id]
      waypoint = Cryal::Waypoint.where(waypoint_name: '100').all.first
      _(waypoint).must_be_nil
    end
  end

  describe 'Security: Waypoints Model' do
    it 'should encrypt waypoint description and coordinates' do
      _, plan = prepare_sample_data
      waypoint = plan.add_waypoint(DATA[:waypoints][0])
      ori_waypoint = DATA[:waypoints][0]
      _(waypoint[:waypoint_lat_secure]).wont_equal ori_waypoint[:latitude]
      _(waypoint[:waypoint_long_secure]).wont_equal ori_waypoint[:longitude]
    end
  end
end

# To create a waypoint, you will need to have a user, a room, user_room, and a plan
def prepare_sample_data
  user = Cryal::Account.create(DATA[:accounts][0])
  room = user.add_room(DATA[:rooms][0])
  user.add_user_room({ room_id: room[:room_id], active: true })
  plan = room.add_plan(DATA[:plans][0])
  [user, plan]
end
