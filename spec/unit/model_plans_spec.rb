# frozen_string_literal: true

# This spec file is to test user model without the need to connect using the API
require_relative '../spec_helper'

describe 'Plans Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
  end

  describe 'HAPPY: Test Plans Model' do
    it 'should get all plans created by the user' do
      _, room = prepare_plan_spec
      room.add_plan(DATA[:plans][0])
      room.add_plan(DATA[:plans][1])
      all_plans = Cryal::Plan.where(room_id: room[:room_id]).all
      _(all_plans.length).must_equal 2
    end

    it 'should store the correct information' do
      _, room = prepare_plan_spec
      plan = room.add_plan(DATA[:plans][0])
      plan_data = DATA[:plans][0]
      _(plan[:plan_name]).must_equal plan_data['plan_name']
      _(plan[:plan_description_secure]).wont_equal plan_data['plan_description']
    end
  end

  describe 'SAD: Test Plans Model' do
    it 'should return nil if plan is not found' do
      _, room = prepare_plan_spec
      plan = room.add_plan(DATA[:plans][0])
      plan[:plan_id]
      plan = Cryal::Plan.where(plan_name: '100').all.first
      _(plan).must_be_nil
    end
  end

  describe 'Security: Test Plans Model' do
    it 'should encrypt plan description' do
      _, room = prepare_plan_spec
      plan = room.add_plan(DATA[:plans][0])
      ori_plan = DATA[:plans][0]
      _(plan[:plan_description_secure]).wont_equal ori_plan[:plan_description]
    end
  end
end

def prepare_plan_spec
  user = Cryal::User.create(DATA[:users][0])
  room = user.add_room(DATA[:rooms][0])
  user.add_user_room({ room_id: room[:room_id], active: true })
  # plan = room.add_plan(DATA[:plans][0])
  [user, room]
end
