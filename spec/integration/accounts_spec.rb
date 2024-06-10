# This spec file is used to test the user model
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    clear_db
    load_seed
  end

  describe 'Account information' do
    it 'HAPPY: should be able to get details of a single account' do
      account_data = DATA[:accounts][1]
      account = Cryal::Account.create(account_data)

      credentials = { username: account_data['username'], password: account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      # get data from the response
      auth = JSON.parse(last_response.body)['attributes']['auth_token']
      header 'AUTHORIZATION', "Bearer #{auth}"
      get "/api/v1/accounts?account_id=#{account.account_id}"
      _(last_response.status).must_equal 200

      attributes = JSON.parse(last_response.body)

      _(attributes['username']).must_equal account.username
      _(attributes['salt']).must_be_nil
      _(attributes['password']).must_be_nil
      _(attributes['password_hash']).must_be_nil
    end
  end

  describe 'Account Creation' do
    before do
      @account_data = DATA[:accounts][1]
    end

    it 'HAPPY: should be able to create new accounts' do
      post 'api/v1/accounts', @account_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      account = Cryal::Account.first
      _(created['username']).must_equal @account_data['username']
      _(created['email']).must_equal @account_data['email']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'BAD: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
