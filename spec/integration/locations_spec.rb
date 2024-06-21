# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Locations Handling' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    clear_db
    load_seed
  end

  describe 'Getting locations' do # rubocop:disable Metrics/BlockLength
    describe 'Getting list of locations' do # rubocop:disable Metrics/BlockLength
      before do
        @account_data = DATA[:accounts][0]
        account = Cryal::Account.create(@account_data)
        account.add_location(DATA[:locations][0])
        account.add_location(DATA[:locations][1])
      end

      it 'HAPPY: should get list for authorized account' do
        # Cryal::Authenticate.call(routing, json)
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        header 'AUTHORIZATION', "Bearer #{auth}"
        get 'api/v1/locations'
        _(last_response.status).must_equal 200

        result = JSON.parse(last_response.body)

        _(result.length).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/locations'
        _(last_response.status).must_equal 403

        result = JSON.parse(last_response.body)
        _(result['data']).must_be_nil
      end

      it 'SECURITY: should prevent basic SQL injection targeting IDs' do
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        header 'AUTHORIZATION', "Bearer #{auth}"

        get 'api/v1/locations/2%20or%20id%3E0'
        # deliberately not reporting error -- don't give attacker information
        _(last_response.status).must_equal 404
        _(last_response.body['data']).must_be_nil
      end
    end

    describe 'Creating New Locations' do # rubocop:disable Metrics/BlockLength
      before do
        clear_db
        @account_data = DATA[:accounts][0]
        Cryal::Account.create(@account_data)
        @req_header = { 'CONTENT_TYPE' => 'application/json' }
        @location_data = DATA[:locations][1]
      end

      it 'HAPPY: should be able to create new locations' do
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
        body = @location_data.to_json

        post 'api/v1/locations', body, headers
        _(last_response.status).must_equal 201
        # _(last_response.headers['Location'].size).must_be :>, 0

        created = JSON.parse(last_response.body)['data']
        proj = Cryal::Location.first

        _(created['location_id']).must_equal proj.location_id
      end

      it 'SECURITY: should not create location with mass assignment' do
        bad_data = @location_data.clone
        bad_data['created_at'] = '1900-01-01'

        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
        body = bad_data.to_json

        post 'api/v1/locations', body, headers

        _(last_response.status).must_equal 400
        # _(last_response.headers['Location']).must_be_nil
      end
    end
  end
end
