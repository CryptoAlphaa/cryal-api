# This spec file is used to test the user_room model
# We want to test the API to properly interact with the user_room model
# We will test the GET and POST routes for the user_room model

# frozen_string_literal: true

require_relative '../spec_helper'

# describe 'Test UserRoom Model' do # rubocop:disable Metrics/BlockLength
#   before do
#     clear_db
#     load_seed

#     # because user_room needs a foreign key of users and rooms, we need to insert them first
#     first_user = Cryal::Account.create(DATA[:accounts][0])
#     second_user = Cryal::Account.create(DATA[:accounts][1])
#     first_user.add_room(DATA[:rooms][0])
#     room_data = Cryal::Room.where(room_name: 'Meeting Room 1').first
#     prepare_to_join_room = { room_id: room_data[:room_id], active: true }
#     second_user.add_user_room(prepare_to_join_room)
#   end

#   describe 'HAPPY: Test GET' do
#     it 'should get all userrooms' do
#       get 'api/v1/userrooms'
#       _(last_response.status).must_equal 200
#       user_rooms = JSON.parse(last_response.body)
#       _(user_rooms.length).must_equal 1
#     end
#   end

#   describe 'HAPPY: Test POST' do
#     it 'should create a new userroom' do
#       # use api/v1/accounts/account_id/joinroom/room_id to create a new user_room
#       third_user = Cryal::Account.create(DATA[:accounts][2])
#       room_data = Cryal::Room.where(room_name: 'Meeting Room 1').first
#       account_id = third_user[:account_id]
#       password = DATA[:rooms][0]['room_password']
#       prepare_to_join_room = { room_id: room_data[:room_id], active: true, room_password: password }
#       post "api/v1/accounts/#{account_id}/joinroom", prepare_to_join_room.to_json
#       _(last_response.status).must_equal 201
#       user_room = JSON.parse(last_response.body)
#       _(user_room['data']).wont_be_nil
#     end
#   end

#   describe 'SAD: Test POST' do
#     it 'should return 404 if data is invalid' do
#       post 'api/v1/accounts/100/joinroom', {}.to_json
#       _(last_response.status).must_equal 404
#     end
#   end
# end


describe 'Test UserRoom Handling' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    clear_db
    load_seed
  end

  describe 'Getting joined rooms' do
    describe 'Getting list of userrooms' do
      before do
        @account_data = DATA[:accounts][0]
        @second_account = DATA[:accounts][1]
        account = Cryal::Account.create(@account_data)
        account2 = Cryal::Account.create(@second_account)
        room1 = account.add_room(DATA[:rooms][0])

        account.add_user_room(room_id: room1.room_id, active: true, authority: "admin")
        room2 = account.add_room(DATA[:rooms][1])
        account.add_user_room(room_id: room2.room_id, active: true, authority: "admin")
        
        room3 = account2.add_room(DATA[:rooms][2])
        account2.add_user_room(room_id: room3.room_id, active: true, authority: "admin")
      end

      it 'HAPPY: should get list of joined rooms for authorized account' do
        # Cryal::Authenticate.call(routing, json)
        credentials = { username: @account_data['username'], password: @account_data['password'] }
        post 'api/v1/auth/authentication', credentials.to_json, @req_header
        # get data from the response
        auth = JSON.parse(last_response.body)['attributes']['auth_token']
        header 'AUTHORIZATION', "Bearer #{auth}"
        get 'api/v1/rooms'
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result.length).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/rooms'
        _(last_response.status).must_equal 403

        result = JSON.parse(last_response.body)
        _(result['data']).must_be_nil
      end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      get 'api/v1/rooms/2%20or%20id%3E0'
      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end


  describe 'Joining existing Rooms' do
    before do
      clear_db
      room_creator = Cryal::Account.create(DATA[:accounts][1])
      desired_room = room_creator.add_room(DATA[:rooms][1])
      @generated_room = desired_room
      room_creator.add_user_room(room_id: desired_room.room_id, active: true, authority: "admin")
      @account_data = DATA[:accounts][0]
      account = Cryal::Account.create(@account_data)
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @desired_room_data = DATA[:rooms][1]
    end

    it 'HAPPY: should be able to join existing rooms' do

      credentials = { username: @account_data['username'], password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      # get data from the response
      auth = JSON.parse(last_response.body)['attributes']['auth_token']
      headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
      
      body = { active: true, room_id: @generated_room.room_id,
              room_password: @desired_room_data['room_password'], 
              authority: "member" }.to_json

      post 'api/v1/rooms/joinroom', body, headers
      _(last_response.status).must_equal 201
      # _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      database_rooms = Cryal::Room.first

      # _(created['room_id']).must_equal database_rooms.room_id
      _(created['active']).must_equal true
      _(created['authority']).must_equal "member"
    end

    it 'SAD: should not join room with wrong password' do
      credentials = { username: @account_data['username'], password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      # get data from the response
      auth = JSON.parse(last_response.body)['attributes']['auth_token']
      headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
      
      body = { room_id: @generated_room.room_id, room_password: "bad_password", authority: "member" }.to_json

      post 'api/v1/rooms/joinroom', body, headers
      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should not create project with mass assignment' do
      body = { bad_key: "bad", room_id: @generated_room.room_id, room_password: "bad_password", authority: "member" }.to_json

      credentials = { username: @account_data['username'], password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      # get data from the response
      auth = JSON.parse(last_response.body)['attributes']['auth_token']
      headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }

      post 'api/v1/rooms/createroom', body, headers

      _(last_response.status).must_equal 400
      # _(last_response.headers['Location']).must_be_nil
    end
  end
end
end