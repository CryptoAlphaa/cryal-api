# This spec file is used to test the waypoints model
# frozen_string_literal: true

require_relative '../spec_helper'

# describe 'Test Waypoints Model' do # rubocop:disable Metrics/BlockLength
#   before do
#     clear_db
#     load_seed
#   end

#   describe 'HAPPY: Test GET' do
#     it 'should get all waypoints for a plan' do
#       user, plan = populate
#       # make one waypoint
#       plan.add_waypoint(DATA[:waypoints][0])
#       account_id = user[:account_id]
#       get "api/v1/accounts/#{account_id}/plans/#{plan[:plan_id]}/waypoints"
#       _(last_response.status).must_equal 200
#       waypoints = JSON.parse(last_response.body)
#       _(waypoints.length).must_equal 1
#     end
#   end

#   describe 'SAD: Test GET' do
#     it 'should return 404 if plan not found' do
#       user, = populate
#       account_id = user[:account_id]
#       get "api/v1/accounts/#{account_id}/plans/100/waypoints"
#       _(last_response.status).must_equal 404
#     end

#     it 'should return 404 if user not found' do
#       get 'api/v1/accounts/100/plans/100/waypoints'
#       _(last_response.status).must_equal 404
#     end
#   end

#   describe 'HAPPY: Test POST' do
#     it 'should create a new waypoint for a plan' do
#       user, plan = populate
#       account_id = user[:account_id]
#       plan_id = plan[:plan_id]
#       post "api/v1/accounts/#{account_id}/plans/#{plan_id}/waypoints", DATA[:waypoints][1].to_json
#       _(last_response.status).must_equal 201
#       waypoint = JSON.parse(last_response.body)['data']
#       _(waypoint['waypoint_id']).wont_be_nil
#     end
#   end

#   describe 'SAD: Test POST' do
#     it 'should return 404 if plan is not found' do
#       user, = populate
#       account_id = user[:account_id]
#       post "api/v1/accounts/#{account_id}/plans/100/waypoints", DATA[:waypoints][1].to_json
#       _(last_response.status).must_equal 404
#     end

#     it 'should return 404 if user is not found' do
#       post 'api/v1/accounts/100/plans/100/waypoints', DATA[:waypoints][1].to_json
#       _(last_response.status).must_equal 404
#     end
#   end
# end

# def populate
#   first_user = Cryal::Account.create(DATA[:accounts][0])
#   second_user = Cryal::Account.create(DATA[:accounts][1])
#   room = first_user.add_room(DATA[:rooms][0])
#   room_data = Cryal::Room.where(room_name: 'Meeting Room 1').first
#   second_user.add_user_room({ room_id: room_data[:room_id], active: true })
#   plan = room.add_plan(DATA[:plans][0])
#   [second_user, plan]
# end

describe 'Test Plan Handling' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    clear_db
    load_seed
  end

  describe 'Getting Waypoints' do
    describe 'Getting list of Waypoints' do
      before do
        @account_data = DATA[:accounts][0]
        account = Cryal::Account.create(@account_data)
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
        post 'api/v1/auth/authentication', credentials.to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        header 'AUTHORIZATION', "Bearer #{auth}"

        get "api/v1/plans/#{@r1_plan1.plan_id}/waypoints"
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result.length).must_equal 2

        get "api/v1/plans/#{@r2_plan1.plan_id}/waypoints"
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result.length).must_equal 1
      end

      it 'SAD: should not get waypoints for wrong plan' do
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', credentials.to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        header 'AUTHORIZATION', "Bearer #{auth}"
        get "api/v1/plans/1212313/waypoints"
        _(last_response.status).must_equal 404
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get "api/v1/plans/#{@r2_plan1.plan_id}/waypoints"
        _(last_response.status).must_equal 403

        result = JSON.parse(last_response.body)
        _(result['data']).must_be_nil
      end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      credentials = { username: @account_data['username'], password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      # get data from the response
      auth = JSON.parse(last_response.body)['attributes']['auth_token']
      header 'AUTHORIZATION', "Bearer #{auth}"
      get "api/v1/plans/#{@r1_plan1.plan_id}/waypoint?waypoint_number=1\' OR \'1\' = \'1"
      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Waypoints' do
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
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      # get data from the response
      auth = JSON.parse(last_response.body)['attributes']['auth_token']
      headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
      package = @waypoint_data.clone
      body = package.to_json

      post "api/v1/plans/#{@plan1.plan_id}/waypoints", body, headers
      # p "last_response.body: #{last_response.body}"
      _(last_response.status).must_equal 201
     
      # _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      database_waypoint = Cryal::Waypoint.first

      _(created['waypoint_id']).must_equal database_waypoint.waypoint_id
      _(created['waypoint_name']).must_equal @waypoint_data['waypoint_name']
    end

    it 'SAD: should not create plans in unauthorized room' do
      credentials = { username: @account_data['username'], password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      # get data from the response
      auth = JSON.parse(last_response.body)['attributes']['auth_token']
      headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
      package = @plans_data.clone
      body = package.to_json

      post "api/v1/plans/#{@plan2.plan_id}/waypoints", body, headers
      _(last_response.status).must_equal 404
    end

    # it 'SECURITY: should not create project with mass assignment' do
    # credentials = { username: @account_data['username'], password: @account_data['password'] }
    #   post 'api/v1/auth/authentication', credentials.to_json, @req_header
    #   # get data from the response
    #   auth = JSON.parse(last_response.body)['attributes']['auth_token']
    #   headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
    #   package = @plans_data.clone
    #   package['room_name'] = @room1.room_name
    #   package['created_at'] = '1900-01-01'
    #   body = package.to_json

    #   post 'api/v1/plans/create_plan', body, headers

    #   _(last_response.status).must_equal 400
    #   # _(last_response.headers['Location']).must_be_nil
    # end
  end
end
end