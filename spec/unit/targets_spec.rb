# This is spec file for targets model
# We want to test the API to properly interact with the targets model
# We will test the GET and POST routes for the targets model

# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Target Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed

    # fill the target table with the first seed
    app.DB[:targets].insert(DATA[:targets].first)
  end

  describe 'HAPPY: Test GET' do
    it 'should get all targets' do
      get 'api/v1/targets'
      _(last_response.status).must_equal 200
      targets = JSON.parse(last_response.body)
      _(targets.length).must_equal 1
    end

    it 'should get a single target' do
      target_id = DATA[:targets].first
      target_id = target_id['id']
      get "api/v1/targets/#{target_id}"
      _(last_response.status).must_equal 200
      target = JSON.parse(last_response.body)
      _(target['id']).must_equal target_id
    end
  end

  describe 'SAD: Test GET' do
    it 'should return 404 if target is not found' do
      get 'api/v1/targets/100'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY: Test POST' do
    it 'should create a new target' do
      # use the second seed to create a new target
      post 'api/v1/targets', DATA[:targets][1].to_json
      _(last_response.status).must_equal 201
      target = JSON.parse(last_response.body)
      _(target['data']).wont_be_nil
    end
  end

  describe 'SAD: Test POST' do
    it 'should return 400 if data is invalid' do
      post 'api/v1/targets', {}.to_json
      _(last_response.status).must_equal 404
    end
  end
end
