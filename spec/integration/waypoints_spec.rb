# This spec file is used to test the waypoints model
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Plan Handling' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    clear_db
    load_seed
  end

  describe 'Getting Waypoints' do # rubocop:disable Metrics/BlockLength
    describe 'Getting list of Waypoints' do # rubocop:disable Metrics/BlockLength
      before do
        @account_data = DATA[:accounts][0]
        @second_account_data = DATA[:accounts][1]
        account = Cryal::Account.create(@account_data)
        second_account = Cryal::Account.create(@second_account_data)
        @room1 = account.add_room(DATA[:rooms][0])
        account.add_user_room(room_id: @room1.room_id, active: true)
        @r1_plan1 = @room1.add_plan(DATA[:plans][0])
        @waypoint1 = @r1_plan1.add_waypoint(DATA[:waypoints][0])
        @waypoint2 = @r1_plan1.add_waypoint(DATA[:waypoints][1])

        @room2 = account.add_room(DATA[:rooms][1])
        account.add_user_room(room_id: @room2.room_id, active: true)
        @r2_plan1 = @room2.add_plan(DATA[:plans][2])
        @waypoint3 = @r2_plan1.add_waypoint(DATA[:waypoints][2])
      end

      it 'HAPPY: should get list of all waypoints in a specific plan' do
        # Cryal::Authenticate.call(routing, json)
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        header 'AUTHORIZATION', "Bearer #{auth}"

        get "api/v1/rooms/#{@room1.room_id}/plans/#{@r1_plan1.plan_id}/waypoints"
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result.length).must_equal 2

        get "api/v1/rooms/#{@room1.room_id}/plans/#{@r1_plan1.plan_id}/waypoints?waypoint_number=1"
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result.length).must_equal 2

        get "api/v1/rooms/#{@room2.room_id}/plans/#{@r2_plan1.plan_id}/waypoints"
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result['data'].length).must_equal 1
      end

      it 'SAD: should not get waypoints for wrong plan' do
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        header 'AUTHORIZATION', "Bearer #{auth}"

        get "api/v1/rooms/#{@room1.room_id}/plans/12312312314/waypoints"
        _(last_response.status).must_equal 404
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get "api/v1/rooms/#{@room1.room_id}/plans/#{@r1_plan1.plan_id}/waypoints"
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
        get "api/v1/rooms/#{@room1.room_id}/plans/#{@r1_plan1.plan_id}/waypoints?waypoint_number=1\' OR \'1\' = \'1"
        # deliberately not reporting error -- don't give attacker information
        _(last_response.status).must_equal 404
        _(last_response.body['data']).must_be_nil
      end

      it 'HAPPY: should delete a single waypoint' do
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }

        delete "api/v1/rooms/#{@room1.room_id}/plans/#{@r1_plan1.plan_id}/waypoints?waypoint_id=#{@waypoint1.waypoint_id}", {}, headers
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result['data']).must_be_nil
      end

      it 'BAD: should not delete a single waypoint for unauthorized user' do
        credentials = { username: @second_account_data['username'], password: @second_account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }

        delete "api/v1/rooms/#{@room1.room_id}/plans/#{@r1_plan1.plan_id}/waypoints?waypoint_number=#{@waypoint1.waypoint_number}", {}, headers
        _(last_response.status).must_equal 403
      end
    end

    describe 'Creating New Waypoints' do # rubocop:disable Metrics/BlockLength
      before do
        clear_db
        @account_data = DATA[:accounts][0]
        account = Cryal::Account.create(@account_data)
        @req_header = { 'CONTENT_TYPE' => 'application/json' }
        @room1 = account.add_room(DATA[:rooms][0])
        account.add_user_room(room_id: @room1.room_id, active: true)
        @plan1 = @room1.add_plan(DATA[:plans][0])

        other_user = Cryal::Account.create(DATA[:accounts][1])
        @room2 = other_user.add_room(DATA[:rooms][1])
        other_user.add_user_room(room_id: @room2.room_id, active: true)
        @plan2 = @room2.add_plan(DATA[:plans][1])

        @waypoint_data = DATA[:waypoints][0]
      end

      it 'HAPPY: should be able to add waypoint in their authorized plan' do
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
        package = @waypoint_data.clone
        body = package.to_json

        post "api/v1/rooms/#{@room1.room_id}/plans/#{@plan1.plan_id}/waypoints", body, headers
        # post "api/v1/plans/#{@plan1.plan_id}/waypoints", body, headers
        # p "last_response.body: #{last_response.body}"
        _(last_response.status).must_equal 201

        # _(last_response.headers['Location'].size).must_be :>, 0

        created = JSON.parse(last_response.body)['data']
        database_waypoint = Cryal::Waypoint.first

        _(created['waypoint_id']).must_equal database_waypoint.waypoint_id
        _(created['waypoint_name']).must_equal @waypoint_data['waypoint_name']
      end

      it 'SAD: should not create waypoints in unauthorized room' do
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
        package = @plans_data.clone
        body = package.to_json

        post "api/v1/rooms/#{@room2.room_id}/plans/#{@plan2.plan_id}/waypoints", body, headers
        _(last_response.status).must_equal 403
      end

      it 'SECURITY: should not create waypoints with mass assignment' do
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', SignedRequest.new(app.config).sign(credentials).to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
        package = @waypoint_data.clone
        package['created_at'] = '1900-01-01'
        body = package.to_json

        post "api/v1/rooms/#{@room1.room_id}/plans/#{@plan1.plan_id}/waypoints", body, headers

        _(last_response.status).must_equal 400
      end
    end
  end
end
