# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Authentication Routes' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    clear_db
    load_seed
  end

  describe 'Account Authentication' do
    before do
      @account_data = DATA[:accounts][1]
      @account = Cryal::Account.create(@account_data)
    end

    it 'HAPPY: should authenticate valid credentials' do
      credentials = { username: @account_data['username'],
                      password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      auth_account = JSON.parse(last_response.body)
      
      account = auth_account['attributes']['account']
      _(last_response.status).must_equal 200
      _(account['username']).must_equal(@account_data['username'])
      _(account['email']).must_equal(@account_data['email'])
    end

    it 'BAD: should not authenticate invalid password' do
      credentials = { username: @account_data['username'],
                      password: 'fakepassword123' }

      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['attributes']).must_be_nil
    end
  end
end