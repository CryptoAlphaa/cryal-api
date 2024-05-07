# frozen_string_literal: true

# This spec file is to test Room model without the need to connect using the API
require_relative '../spec_helper'

describe 'Room Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
  end

  describe 'HAPPY: Test Room Model' do
    it 'should create a room and retrieve it' do
      user = Cryal::Account.create(DATA[:accounts][0])
      room = user.add_room(DATA[:rooms][0])
      _(room[:room_id]).wont_be_nil
    end

    it 'should retrieve all rooms' do
      user = Cryal::Account.create(DATA[:accounts][0])
      user.add_room(DATA[:rooms][0])
      user2 = Cryal::Account.create(DATA[:accounts][1])
      user2.add_room(DATA[:rooms][1])
      rooms = Cryal::Room.all
      _(rooms.length).must_equal 2
    end

    it 'should retrieve a single room by id' do
      user = Cryal::Account.create(DATA[:accounts][0])
      room = user.add_room(DATA[:rooms][0])
      room_id = room[:room_id]
      room = Cryal::Room[room_id]
      _(room[:room_id]).wont_be_nil
    end
  end

  describe 'SAD: Test Room Model' do
    it 'should return nil if room is not found' do
      user = Cryal::Account.create(DATA[:accounts][0])
      user.add_room(DATA[:rooms][0])
      search = Cryal::Room.where(room_name: 'not_a_room').first
      _(search).must_be_nil
    end
  end

  describe 'SECURITY: Test Room Model' do
    it 'should encrypt room password' do
      user = Cryal::Account.create(DATA[:accounts][0])
      room = user.add_room(DATA[:rooms][0])
      ori_room = DATA[:rooms][0]
      _(room[:room_password_hash]).wont_equal ori_room['password']
    end
  end
end
