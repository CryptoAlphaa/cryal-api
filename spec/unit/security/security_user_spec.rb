# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test User Model' do
  before do
    clear_db
    load_seed

    # fill the user table with the first seed
    app.DB[:users].insert(DATA[:users].first)
  end

  describe 'SECURITY: mass assignment attacks' do
    it 'should not allow changing user password' do
      user = User.first(user_id: DATA[:users].first[:id])
      original_password = user.password
      post "api/v1/users/#{user.id}", { password: 'new_password' }.to_json
      user.refresh
      _(user.password).must_equal original_password  # Ensure password has not changed
    end
  end

  describe 'SECURITY: SQL injection prevention' do
    it 'should prevent basic SQL injection to get index' do
        get 'api/v1/users/2%20or%20id%3D1'
        _(last_response.status).must_equal 404
        #_(last_response.body['data']).must_be_nil
        _(app.DB[:users].count).wont_equal 0
      end
  end

  describe 'SECURITY: non-deterministic UUIDs' do
    it 'should generate non-deterministic UUIDs' do
      post 'api/v1/users', { name: 'New User' }.to_json
      first_user = JSON.parse(last_response.body)['data']
      post 'api/v1/users', { name: 'Another User' }.to_json
      second_user = JSON.parse(last_response.body)['data']
      _(first_user['id']).wont_equal second_user['id']
    end
  end

  describe 'SECURITY: secured data fields' do
    # it 'should encrypt and decrypt sensitive data fields' do
    #   get 'api/v1/users'
    #   users = JSON.parse(last_response.body)
    #   _(users.any? { |u| u.key?('password') }).must_equal false
    # end
    it 'should not expose encrypted or sensitive user fields' do
      get 'api/v1/users'
      users = JSON.parse(last_response.body)
      users.each do |user|
        _(user.keys).wont_include 'password'
      end
    end
  end
end
