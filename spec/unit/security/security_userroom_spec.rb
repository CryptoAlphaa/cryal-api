# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test UserRoom Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # because user_room needs a foreign key of users and rooms, we need to insert them first
    app.DB[:users].insert(DATA[:users][0])
    app.DB[:targets].insert(DATA[:targets][0])
    app.DB[:rooms].insert(DATA[:rooms][0])
    app.DB[:user_rooms].insert(DATA[:user_rooms][0])
  end

  describe 'SECURITY: Test Authorization' do
    it 'should prevent unauthorized users from joining a room' do
      post 'api/v1/users/100/joinroom', DATA[:user_rooms][1].to_json
      _(last_response.status).must_equal 403
    end
  end

  describe 'SECURITY: Test Authentication' do
    it 'should prevent unauthenticated users from joining a room' do
      post 'api/v1/users/1/joinroom', DATA[:user_rooms][1].to_json
      _(last_response.status).must_equal 401
    end
  end
end
