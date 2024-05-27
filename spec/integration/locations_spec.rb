# # This spec file is used to test the location model
# # We want to test the API to properly interact with the user model
# # We will test the GET and POST routes for the user model

# # frozen_string_literal: true

# require_relative '../spec_helper'

# describe 'Test Location Model' do # rubocop:disable Metrics/BlockLength
#   before do
#     clear_db
#     load_seed
#     first_data = Cryal::Account.create(DATA[:accounts].first)
#     first_data.add_location(DATA[:locations].first)
#   end

#   describe 'HAPPY: Test GET' do
#     it 'should get all locations for a user' do
#       account_id = Cryal::Account.create(DATA[:accounts][1])
#       account_id.add_location(DATA[:locations].first)
#       account_id = account_id[:account_id]
#       get "api/v1/accounts/#{account_id}/locations"
#       _(last_response.status).must_equal 200
#       locations = JSON.parse(last_response.body)
#       _(locations.length).must_equal 1
#     end
#   end

#   describe 'SAD: Test GET' do
#     it 'should return 404 if user not found' do
#       Cryal::Account.first
#       account_id = 100
#       get "api/v1/accounts/#{account_id}/locations"
#       _(last_response.status).must_equal 404
#     end
#   end

#   describe 'HAPPY: Test POST' do
#     it 'should create a new location for a user' do
#       account_id = Cryal::Account.create(DATA[:accounts][1])
#       account_id = account_id[:account_id]
#       # use the second seed to create a new location
#       post "api/v1/accounts/#{account_id}/locations", DATA[:locations][1].to_json
#       _(last_response.status).must_equal 201
#       location = JSON.parse(last_response.body)
#       _(location['data']).wont_be_nil
#     end
#   end

#   describe 'SAD: Test POST' do
#     it 'should return 404 if user is not found' do
#       post 'api/v1/accounts/100/locations', DATA[:locations][2].to_json
#       _(last_response.status).must_equal 404
#     end
#   end
# end

# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    clear_db
    load_seed
  end

  describe 'Getting locations' do
    describe 'Getting list of locations' do
      before do
        @account_data = DATA[:accounts][0]
        account = Cryal::Account.create(@account_data)
        account.add_location(DATA[:locations][0])
        account.add_location(DATA[:locations][1])
      end

      it 'HAPPY: should get list for authorized account' do
        # Cryal::Authenticate.call(routing, json)
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', credentials.to_json, @req_header
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
      get 'api/v1/locations/2%20or%20id%3E0'
      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end


  describe 'Creating New Locations' do
    before do
      clear_db
      @account_data = DATA[:accounts][0]
      account = Cryal::Account.create(@account_data)
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @location_data = DATA[:locations][1]
    end

    it 'HAPPY: should be able to create new locations' do

      credentials = { username: @account_data['username'], password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
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
      _(created['name']).must_equal @location_data['name']
    end

    it 'SECURITY: should not create project with mass assignment' do
      bad_data = @location_data.clone
      bad_data['created_at'] = '1900-01-01'

      credentials = { username: @account_data['username'], password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
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