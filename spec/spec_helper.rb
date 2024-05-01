# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require 'fileutils'
require 'sequel'

require_relative 'test_load_all'

def clear_db
  app.DB[:users].delete
  app.DB[:locations].delete
  app.DB[:rooms].delete
  app.DB[:user_rooms].delete
  app.DB[:targets].delete
  # reset the auto increment
  app.DB[:sqlite_sequence].where(name: 'users').delete
  app.DB[:sqlite_sequence].where(name: 'locations').delete
  app.DB[:sqlite_sequence].where(name: 'rooms').delete
  app.DB[:sqlite_sequence].where(name: 'user_rooms').delete
  app.DB[:sqlite_sequence].where(name: 'plans').delete
  app.DB[:sqlite_sequence].where(name: 'waypoints').delete
end

DATA = {} # rubocop:disable Style/MutableConstant

def load_seed
  DATA[:users] = YAML.safe_load_file('app/db/seeds/users_seeds.yml')
  DATA[:locations] = YAML.safe_load_file('app/db/seeds/locations_seeds.yml')
  DATA[:rooms] = YAML.safe_load_file('app/db/seeds/rooms_seeds.yml')
  DATA[:user_rooms] = YAML.safe_load_file('app/db/seeds/user_rooms_seeds.yml')
  DATA[:plans] = YAML.safe_load_file('app/db/seeds/plans_seeds.yml')
  DATA[:waypoints] = YAML.safe_load_file('app/db/seeds/waypoints_seeds.yml')
end
