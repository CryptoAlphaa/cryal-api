# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test Waypoint Model' do
  before do
    clear_db
    load_seed
    # to create a waypoint, we need a user, room, user_room, plan, and waypoint
  end

    describe 'SECURITY: Mass Assignment' do
        it 'should not allow post to change id' do
            post_item = DATA[:waypoints][4]
            post_item[:waypoint_id] = 1
            data = Populate()
            user_id = data[0][:user_id]
            plan_id = data[1][:plan_id]
            post "api/v1/users/#{user_id}/plans/#{plan_id}/waypoints", post_item.to_json
            _(last_response.status).must_equal 400
            _(last_response.body['data']).must_be_nil
        end
    end

    describe 'SECURITY: SQL Injection' do
        it 'should prevent SQL injection to get index' do
            get 'api/v1/users/2%20or%20id%3D1/plans/1/waypoints'
            _(last_response.status).must_equal 404
            _(last_response.body['data']).must_be_nil
        end
    end

    describe 'SECURITY: Non-deterministic UUIDs' do
        it 'should generate non-deterministic UUIDs' do
            data = Populate()
            user_id = data[0][:user_id]
            plan_id = data[1][:plan_id]
            post_item = { waypoint_name: 'New Waypoint', latitude: '1.0', longitude: '1.0'}
            post "api/v1/users/#{user_id}/plans/#{plan_id}/waypoints", post_item.to_json
            first_waypoint = JSON.parse(last_response.body)['data']
            post_item = { waypoint_name: 'New Waypoint 2', latitude: '1.0', longitude: '1.0'}
            post "api/v1/users/#{user_id}/plans/#{plan_id}/waypoints", post_item.to_json
            second_waypoint = JSON.parse(last_response.body)['data']
            _(first_waypoint['waypoint_id']).wont_equal(second_waypoint['waypoint_id'])
        end
    end

    describe 'SECURITY: Encrypted Data Fields' do
        it 'should encrypt and decrypt sensitive data fields' do
            data = Populate()
            user_id = data[0][:user_id]
            plan_id = data[1][:plan_id]
            post_item = { waypoint_name: 'New Waypoint 100', latitude: '1.0', longitude: '1.0'}
            post "api/v1/users/#{user_id}/plans/#{plan_id}/waypoints", post_item.to_json
            get "api/v1/users/#{user_id}/plans/#{plan_id}/waypoints"
            waypoints = JSON.parse(last_response.body)[0].to_json
            _(waypoints['waypoint_lat'].to_s).wont_equal(post_item['latitude'].to_s)
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
    prepare_plan = DATA[:plans][0]
    # prepare_plan[:room_id] = room_data[:room_id]
    plan = room.add_plan(prepare_plan)
    return second_user, plan
end