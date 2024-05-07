# This spec file is used to test the user model
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Accounts Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
    Cryal::Account.create(DATA[:accounts].first)
  end

  describe 'HAPPY: Test GET' do
    it 'should get all users' do
      get 'api/v1/accounts'
      _(last_response.status).must_equal 200
      users = JSON.parse(last_response.body)
      _(users.length).must_equal 1
    end

    it 'should get a single user' do
      test_user = Cryal::Account.create(DATA[:accounts][1])
      account_id = test_user[:account_id]
      get "api/v1/accounts/#{account_id}"
      _(last_response.status).must_equal 200
      user = JSON.parse(last_response.body)
      _(user['account_id']).wont_be_nil
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if user is not found' do
      get 'api/v1/accounts/100'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY Test POST' do
    it 'should create a new user' do
      # use the second seed to create a new user
      post 'api/v1/accounts', DATA[:accounts][1].to_json
      _(last_response.status).must_equal 201
      user = JSON.parse(last_response.body)
      _(user['data']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 400 if server error' do
      post 'api/v1/accounts', { username: 'ubi', password: 'bola', email_secure: 'kocak' }.to_json
      _(last_response.status).must_equal 400
    end
  end
end
