# This spec file is used to test the user model
# We want to test the API to properly interact with the user model
# We will test the GET and POST routes for the user model

# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test User Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # fill the user table with the first seed
    app.DB[:users].insert(DATA[:users].first)
  end

  describe 'HAPPY: Test GET' do
    it 'should get all users' do
      get 'api/v1/users'
      _(last_response.status).must_equal 200
      users = JSON.parse(last_response.body)
      _(users.length).must_equal 1
    end

    it 'should get a single user' do
      user_id = DATA[:users].first
      user_id = user_id['id']
      get "api/v1/users/#{user_id}"
      _(last_response.status).must_equal 200
      user = JSON.parse(last_response.body)
      _(user['id']).must_equal user_id
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
    it 'should return 404 if data is invalid' do
      post 'api/v1/users', {}.to_json
      _(last_response.status).must_equal 404
    end
  end
end