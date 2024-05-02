# This spec file is used to test the user model
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test User Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # fill the user table with the first seed
    DATA[:users].each do |user|
      Cryal::User.create(user)
      break
    end
  end

  describe 'HAPPY: Test GET' do
    it 'should get all users' do
      get 'api/v1/users'
      _(last_response.status).must_equal 200
      users = JSON.parse(last_response.body)
      _(users.length).must_equal 1
    end

    it 'should get a single user' do
      test_user = Cryal::User.create(DATA[:users][1])
      user_id = test_user[:user_id]
      get "api/v1/users/#{user_id}"
      _(last_response.status).must_equal 200
      user = JSON.parse(last_response.body)
      _(user['user_id']).wont_be_nil
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if user is not found' do
      get 'api/v1/users/100'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY Test POST' do
    it 'should create a new user' do
      # use the second seed to create a new user
      post 'api/v1/users', DATA[:users][1].to_json
      _(last_response.status).must_equal 201
      user = JSON.parse(last_response.body)
      _(user['data']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 500 if server error' do
      post 'api/v1/users', {}.to_json
      _(last_response.status).must_equal 500
    end
  end
end
