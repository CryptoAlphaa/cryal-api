# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/routes'

# Use rack/test in your tests to call your API and check the last_response object
# Create at least 4 tests:
# HAPPY tests:
# Test if the root route works
# Test if creating a resource (POST method) works
# Test if getting a single resource (GET) works
# Test if getting a list of resources (GET) works
# SAD tests:
# Make sure that trying to GET a non-existent resource fails

def app
  Cryal::Api
end

DATA = YAML.safe_load File.read('app/db/seeds/routes_seeds.yml')

describe 'Test API routes' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    Cryal::Routes.setup

    # delete all files in store, populate with seed data from index 2 to 5
    Dir.glob("#{Cryal::STORE_DIR}/*.txt").each { |f| File.delete(f) }
    DATA[2..4].each do |route|
      Cryal::Routes.new(route).save # populate with unused seed data
    end
  end

  describe 'HAPPY: Test API routes' do
    it 'should get the root route' do
      get '/'
      _(last_response.status).must_equal 200
      _(last_response.body).must_include 'Welcome to Cryal API'
    end

    it 'should get a list of routes' do
      get 'api/routes'
      _(last_response.status).must_equal 200
      routes = JSON.parse last_response.body
      _(routes['document_ids'].count).must_equal 3
    end

    it 'should create a new route' do
      post 'api/routes', DATA[0].to_json, { 'CONTENT_TYPE' => 'application/json' }
      _(last_response.status).must_equal 201
      route = JSON.parse last_response.body
      _(route['id']).must_equal DATA[0]['id']
    end

    it 'should get a single route' do
      post 'api/routes', DATA[1].to_json, { 'CONTENT_TYPE' => 'application/json' }
      route = JSON.parse last_response.body
      get "api/routes/#{route['id']}"
      _(last_response.status).must_equal 200
      route = JSON.parse last_response.body
      _(route['origin']).must_equal DATA[1]['origin']
    end
  end

  describe 'SAD: Test API routes' do
    it 'should return an error for a missing route' do
      get '/routes/foobar'
      _(last_response.status).must_equal 404
    end
  end
end
