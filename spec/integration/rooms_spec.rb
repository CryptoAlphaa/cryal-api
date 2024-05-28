# # This is spec file for rooms model
# # We want to test the API to properly interact with the rooms model
# # We will test the GET and POST routes for the rooms model
# # frozen_string_literal: true

require_relative '../spec_helper'

# describe 'Test Room Model' do # rubocop:disable Metrics/BlockLength
#   before do
#     clear_db
#     load_seed
#     first_account = Cryal::Account.create(DATA[:accounts][0])
    
#     first_account.add_room(DATA[:rooms][0]) # create first room
#     second_account = Cryal::Account.create(DATA[:accounts][1])
#     second_room = second_account.add_room(DATA[:rooms][1]) # create second room
    
#     @account_data = DATA[:accounts][0]
#     @req_header
#   end

#   describe 'HAPPY: Test GET' do
#     it 'should get rooms for authorized user' do

#       credentials = { username: @account_data['username'], password: @account_data['password'] }
#       post 'api/v1/auth/authentication', credentials.to_json, @req_header
#       # get data from the response
#       auth = JSON.parse(last_response.body)['attributes']['auth_token']
#       header 'AUTHORIZATION', "Bearer #{auth}"
#       get 'api/v1/rooms'
#       _(last_response.status).must_equal 200
#       rooms = JSON.parse(last_response.body)
#       _(rooms.length).must_equal 1
#     end
#   end

#   # describe 'HAPPY: Test POST' do
#   #   it 'should create a new room by a user' do
#   #     # use the second seed to create a new room
#   #     # but first we need to insert the user and target
#   #     new_user = Cryal::Account.create(DATA[:accounts][1])
#   #     account_id = new_user[:account_id]
#   #     post "api/v1/accounts/#{account_id}/createroom", DATA[:rooms][1].to_json
#   #     _(last_response.status).must_equal 201
#   #     room = JSON.parse(last_response.body)
#   #     _(room['data']).wont_be_nil
#   #   end
#   # end

#   # describe 'SAD: Test POST' do
#   #   it 'should return 404 if user does not exist' do
#   #     post 'api/v1/accounts/2/createroom', {}.to_json
#   #     _(last_response.status).must_equal 404
#   #   end
#   # end
# end


describe 'Test Room Handling' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    clear_db
    load_seed
  end

  describe 'Getting Rooms' do
    describe 'Getting list of rooms' do
      before do
        @account_data = DATA[:accounts][0]
        @second_account = DATA[:accounts][1]
        account = Cryal::Account.create(@account_data)
        account2 = Cryal::Account.create(@second_account)
        room1 = account.add_room(DATA[:rooms][0])

        account.add_user_room(room_id: room1.room_id, active: true)
        room2 = account.add_room(DATA[:rooms][1])
        account.add_user_room(room_id: room2.room_id, active: true)
        
        room3 = account2.add_room(DATA[:rooms][2])
        account2.add_user_room(room_id: room3.room_id, active: true)
      end

      it 'HAPPY: should get list for authorized account' do
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


  describe 'Creating New Rooms' do
    before do
      clear_db
      @account_data = DATA[:accounts][0]
      account = Cryal::Account.create(@account_data)
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @room_data = DATA[:rooms][1]
    end

    it 'HAPPY: should be able to create new rooms' do

      credentials = { username: @account_data['username'], password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      # get data from the response
      auth = JSON.parse(last_response.body)['attributes']['auth_token']
      headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
      body = @room_data.to_json

      post 'api/v1/rooms/createroom', body, headers
      _(last_response.status).must_equal 201
      # _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      database_rooms = Cryal::Room.first

      _(created['room_id']).must_equal database_rooms.room_id
      _(created['room_name']).must_equal @room_data['room_name']
    end

    it 'SECURITY: should not create project with mass assignment' do
      bad_data = @room_data.clone
      bad_data['created_at'] = '1900-01-01'

      credentials = { username: @account_data['username'], password: @account_data['password'] }
      post 'api/v1/auth/authentication', credentials.to_json, @req_header
      # get data from the response
      auth = JSON.parse(last_response.body)['attributes']['auth_token']
      headers = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{auth}" }
      body = bad_data.to_json

      post 'api/v1/rooms/createroom', body, headers

      _(last_response.status).must_equal 400
      # _(last_response.headers['Location']).must_be_nil
    end
  end
end
end