# frozen_string_literal: true

require_relative '../spec_helper'

describe 'UserRoom Model' do
  before do
    clear_db
    load_seed
  end

  describe 'HAPPY: Test UserRoom Model' do
    it 'should make a user join a room' do
      _, room = prepare_user_room_data
      new_user = Cryal::User.create(DATA[:users][1])
      sample_room_id = room[:room_id]
      new_user.add_user_room({ room_id: sample_room_id, active: true })
      new_user = Cryal::User_Room.all
      _(new_user.length).must_equal 1
    end
  end

  describe 'SAD: Test UserRoom Model' do
    it 'should NOT allow a user to join a room if it does not exist' do
      prepare_user_room_data
      new_user = Cryal::User.create(DATA[:users][1])
      _(proc {
          new_user.add_user_room({ room_id: 'something', active: true })
        }).must_raise Sequel::ForeignKeyConstraintViolation
      # After the exception is raised, you can continue with your assertions
      new_user = Cryal::User_Room.all
      _(new_user.length).must_equal 0
    end
  end
end

def prepare_user_room_data
  user = Cryal::User.create(DATA[:users][0])
  room = user.add_room(DATA[:rooms][0])
  [user, room]
end
