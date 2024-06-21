# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Authentication Routes' do # rubocop:disable Metrics/BlockLength
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
      body = SignedRequest.new(app.config).sign(credentials).to_json
      post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
      auth_account = JSON.parse(last_response.body)

      account = auth_account['attributes']['account']
      _(last_response.status).must_equal 200
      _(account['username']).must_equal(@account_data['username'])
      _(account['email']).must_equal(@account_data['email'])
    end

    it 'BAD: should not authenticate invalid password' do
      bad_credentials = { username: @account_data['username'],
                          password: 'fakepassword123' }

      post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(bad_credentials).to_json, @req_header
      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['attributes']).must_be_nil
    end
  end

  describe 'SSO Authorization' do
    before do
      WebMock.enable!
      WebMock.stub_request(:get, app.config.GITHUB_ACCOUNT_URL)
             .to_return(body: GH_ACCOUNT_RESPONSE[GOOD_GH_ACCESS_TOKEN],
                        status: 200,
                        headers: { 'content-type' => 'application/json' })
    end

    after do
      WebMock.disable!
    end

    it 'HAPPY AUTH SSO: should authenticate+authorize new valid SSO account' do
      gh_access_token = { access_token: GOOD_GH_ACCESS_TOKEN }

      post 'api/v1/auth/sso', SignedRequest.new(app.config).sign(gh_access_token).to_json, @req_header

      auth_account = JSON.parse(last_response.body)['data']
      account = auth_account['attributes']['account']

      _(last_response.status).must_equal 200
      _(account['username']).must_equal(SSO_ACCOUNT['sso_username'])
      _(account['email']).must_equal(SSO_ACCOUNT['email'])
      _(account['account_id']).must_be_nil
    end

    it 'HAPPY AUTH SSO: should authorize existing SSO account' do
      Cryal::Account.create(
        username: SSO_ACCOUNT['sso_username'],
        email: SSO_ACCOUNT['email'],
        password_hash: 'dummyhash'
      )

      gh_access_token = { access_token: GOOD_GH_ACCESS_TOKEN }
      post 'api/v1/auth/sso', SignedRequest.new(app.config).sign(gh_access_token).to_json, @req_header

      auth_account = JSON.parse(last_response.body)['data']
      account = auth_account['attributes']['account']

      _(last_response.status).must_equal 200
      _(account['username']).must_equal(SSO_ACCOUNT['sso_username'])
      _(account['email']).must_equal(SSO_ACCOUNT['email'])
      _(account['account_id']).must_be_nil
    end
  end
end
