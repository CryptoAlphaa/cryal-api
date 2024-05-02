# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test User Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # fill the user table with the first seed
    DATA[:users].each do |user| # rubocop:disable Lint/UnreachableLoop
      Cryal::User.create(user)
      break
    end
  end

  describe 'SECURITY: mass assignment attacks' do
    it 'should not allow post with specifying user_id' do
      post 'api/v1/users', { username: 'New User', user_id: 1, email: 'a', password: 'braveo' }.to_json
      _(last_response.status).must_equal 400
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'SECURITY: SQL injection prevention' do
    it 'should prevent basic SQL injection to get index' do
      get 'api/v1/users/2%20or%20id%3D1'
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'SECURITY: non-deterministic UUIDs' do
    it 'should generate non-deterministic UUIDs' do
      post 'api/v1/users', { username: 'New User', email: 'a', password: 'braveo' }.to_json
      first_user = JSON.parse(last_response.body)['data']
      post 'api/v1/users', { username: 'Another User', email: 'b', password: 'alpha' }.to_json
      second_user = JSON.parse(last_response.body)['data']
      _(first_user['user_id']).wont_equal(second_user['user_id'])
    end
  end

  describe 'SECURITY: secured data fields' do
    it 'should encrypt and decrypt sensitive data fields' do
      post 'api/v1/users', { username: 'New User', email: 'a', password: 'braveo' }.to_json
      first_user = JSON.parse(last_response.body)['data']
      dummy_id = first_user['user_id']
      get "api/v1/users/#{dummy_id}"
      users = JSON.parse(last_response.body)
      _(users['password_hash']).must_be_nil
    end
  end
end

def deep_key_exists?(hash, key)
  # Check if key is present at the current level
  return true if hash.key?(key)

  # If the key is not at the current level, check nested hashes
  hash.values.any? { |v| deep_key_exists?(v, key) if v.is_a?(Hash) }
end
