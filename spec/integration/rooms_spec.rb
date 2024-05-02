# This is spec file for rooms model
# We want to test the API to properly interact with the rooms model
# We will test the GET and POST routes for the rooms model
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Room Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
    first_data = Cryal::User.create(DATA[:users].first)
    first_data.add_room(DATA[:rooms].first)
  end

  describe 'HAPPY: Test GET' do
    it 'should get all rooms' do
      get 'api/v1/rooms'
      _(last_response.status).must_equal 200
      rooms = JSON.parse(last_response.body)
      _(rooms.length).must_equal 1
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new room by a user' do
      # use the second seed to create a new room
      # but first we need to insert the user and target
      new_user = Cryal::User.create(DATA[:users][1])
      user_id = new_user[:user_id]
      post "api/v1/users/#{user_id}/createroom", DATA[:rooms][1].to_json
      _(last_response.status).must_equal 201
      room = JSON.parse(last_response.body)
      _(room['data']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 404 if user does not exist' do
      post 'api/v1/users/2/createroom', {}.to_json
      _(last_response.status).must_equal 404
    end
  end
end
