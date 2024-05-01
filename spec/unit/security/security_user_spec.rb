# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test User Model' do
  before do
    clear_db
    load_seed

    # fill the user table with the first seed
    app.DB[:users].insert(DATA[:users].first)
  end

  describe 'mass assignment attacks' do
    it 'should not allow changing user password' do
      # IDK
    end
  end

  describe 'SQL injection prevention' do
    it 'should prevent basic SQL injection to get index' do
        get 'api/v1/users/2%20or%20id%3D1'
        _(last_response.status).must_equal 404
        #_(last_response.body['data']).must_be_nil
        _(app.DB[:users].count).wont_equal 0
      end
  end

  describe 'non-deterministic UUIDs' do
    it 'should generate non-deterministic UUIDs' do
      post 'api/v1/users', { name: 'New User' }.to_json
      first_user = JSON.parse(last_response.body)['data']
      post 'api/v1/users', { name: 'Another User' }.to_json
      second_user = JSON.parse(last_response.body)['data']
      _(first_user['id']).wont_equal second_user['id']
    end
  end

  describe 'secured data fields' do
    it 'should encrypt and decrypt sensitive data fields' do
      get 'api/v1/users'
      users = JSON.parse(last_response.body)
      _(users.any? { |u| u.key?('password') }).must_equal false
    end
  end

  describe 'security library cases' do
    it 'should store encrypted passwords' do
      # create a user with a known password
      user = User.create(email: 'test@example.com', password: 'password')
      # Fetch the user directly from the database
      stored_user = User.find(email: 'test@example.com')
      # The stored password should not be the same as the plain text password
      expect(stored_user.password).not_to eq('password')
      # The stored password should be the encrypted version of the plain text password
      expect(stored_user.password).to eq(User.encrypt_password('password'))
    end
  end
end
