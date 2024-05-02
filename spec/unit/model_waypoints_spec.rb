# frozen_string_literal: true

# This spec file is to test user model without the need to connect using the API
require_relative '../spec_helper'

describe 'Waypoints Model' do
    before do
        clear_db
        load_seed
    end
    describe 'HAPPY: Waypoints Model' do
        it 'should get all users and retrieve the correct information' do
            user, plan = PrepareSampleData()
            original_waypoint = DATA[:waypoints][0]
            waypoint = plan.add_waypoint(original_waypoint)
            _(waypoint[:waypoint_name]).must_equal original_waypoint["waypoint_name"]
            _(waypoint[:waypoint_lat_secure]).wont_be_nil
        end
    end

    describe 'SAD: Waypoints Model' do
        it 'should return nil if waypoint is not found' do
            user, plan = PrepareSampleData()
            waypoint = plan.add_waypoint(DATA[:waypoints][0])
            waypoint_id = waypoint[:waypoint_id]
            waypoint = Cryal::Waypoint.where(waypoint_name: "100").all.first
            _(waypoint).must_be_nil
        end
    end

    describe 'Security: Waypoints Model' do
        it 'should encrypt waypoint description and coordinates' do
            user, plan = PrepareSampleData()
            waypoint = plan.add_waypoint(DATA[:waypoints][0])
            ori_waypoint = DATA[:waypoints][0]
            _(waypoint[:waypoint_lat_secure]).wont_equal ori_waypoint[:latitude]
            _(waypoint[:waypoint_long_secure]).wont_equal ori_waypoint[:longitude]
        end
    end
end

# To create a waypoint, you will need to have a user, a room, user_room, and a plan
def PrepareSampleData()
    user = Cryal::User.create(DATA[:users][0])
    room = user.add_room(DATA[:rooms][0])
    user_room = user.add_user_room({ room_id: room[:room_id], active: true })
    plan = room.add_plan(DATA[:plans][0])
    return user, plan
end