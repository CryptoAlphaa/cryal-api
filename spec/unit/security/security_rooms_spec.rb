# frozen_string_literal: true

require_relative './../../spec_helper'

describe 'Security Test Rooms Model' do
  before do
    clear_db
    load_seed
    # because room needs a foreign key of users and targets, we need to insert them first
    app.DB[:users].insert(DATA[:users][0])
    app.DB[:targets].insert(DATA[:targets][0])
    app.DB[:rooms].insert(DATA[:rooms][0])
  end

  describe 'SECURITY: SQL Injection' do
    it 'should prevent SQL injection in room queries' do
      get 'api/v1/rooms/1%20or%20id%3D1'
      _(last_response.status).must_equal 404
      # Verify the rooms table still exists and has data
      _(app.DB[:rooms].count).wont_equal 0
    end
  end

  describe 'SECURITY: Data Exposure' do
    it 'should not expose sensitive room details publicly' do
      get 'api/v1/rooms'
      rooms = JSON.parse(last_response.body)
      rooms.each do |room|
        _(room.key?('precise_coordinates')).must_equal false
      end
    end
  end
end
