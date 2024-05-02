# This spec file is used to test the plans model
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Plans Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
  end

    describe 'HAPPY: Test GET' do
        it 'should get all plans for a user' do
            user, room = PopulatePlan()
            user_id = user[:user_id]
            one_room_name = room[:room_name]
            get "api/v1/users/#{user_id}/plans/fetch/?room_name=#{one_room_name}"
            _(last_response.status).must_equal 200
            plans = JSON.parse(last_response.body)
            _(plans.length).must_equal 1
        end
    end

    describe 'SAD: Test GET' do
        it 'should return 404 if user not found' do
            get "api/v1/users/100/plans"
            _(last_response.status).must_equal 404
        end
    end

    describe 'HAPPY: Test POST' do
        it 'should create a new plan for a user' do
            user, room = PopulatePlan()
            user_id = user[:user_id]
            prepare_plan = DATA[:plans][1]
            prepare_plan[:room_name] = room[:room_name]
            post "api/v1/users/#{user_id}/plans/create_plan", prepare_plan.to_json
            _(last_response.status).must_equal 201
            plan = JSON.parse(last_response.body)['data']
            _(plan['plan_id']).wont_be_nil
        end

        it 'should create a new plan for a user which is in the same room' do
            user, room = PopulatePlan()
            third_user = Cryal::User.create(DATA[:users][2])
            prepare_to_join_room = { room_id: room[:room_id], active: true }
            user_room = third_user.add_user_room(prepare_to_join_room)
            user_id = third_user[:user_id]
            prepare_plan = DATA[:plans][1]
            prepare_plan[:room_name] = room[:room_name]
            post "api/v1/users/#{user_id}/plans/create_plan", prepare_plan.to_json
            _(last_response.status).must_equal 201
            plan = JSON.parse(last_response.body)['data']
            _(plan['plan_id']).wont_be_nil
        end
    end

    describe 'SAD: Test POST' do
        it 'should return 404 if user is not found' do
            user, room = PopulatePlan()
            prepare_plan = DATA[:plans][1]
            prepare_plan[:room_name] = room[:room_name]
            post "api/v1/users/100/plans/create_plan", prepare_plan.to_json
            _(last_response.status).must_equal 404
        end

        it 'should return 404 if user is not in the room' do
            user, room = PopulatePlan()
            third_user = Cryal::User.create(DATA[:users][2])
            user_id = third_user[:user_id]
            prepare_plan = DATA[:plans][1]
            prepare_plan[:room_name] = room[:room_name]
            post "api/v1/users/#{user_id}/plans/create_plan", prepare_plan.to_json
            _(last_response.status).must_equal 404
        end
    end
end

def PopulatePlan
    first_user = Cryal::User.create(DATA[:users][0])
    second_user = Cryal::User.create(DATA[:users][1])
    room = first_user.add_room(DATA[:rooms][0])
    room_data = Cryal::Room.where(room_name: 'Meeting Room 1').first
    prepare_to_join_room = { room_id: room_data[:room_id], active: true }
    user_room = second_user.add_user_room(prepare_to_join_room)
    prepare_plan = DATA[:plans][0]
    # prepare_plan[:room_id] = room_data[:room_id]
    plan = room.add_plan(prepare_plan)
    return second_user, room
end