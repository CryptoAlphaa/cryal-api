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
  app.DB.run("DELETE FROM sqlite_sequence WHERE name='users'")
  app.DB.run("DELETE FROM sqlite_sequence WHERE name='locations'")
  app.DB.run("DELETE FROM sqlite_sequence WHERE name='rooms'")
  app.DB.run("DELETE FROM sqlite_sequence WHERE name='user_rooms'")
  app.DB.run("DELETE FROM sqlite_sequence WHERE name='targets'")
end

DATA = {} # rubocop:disable Style/MutableConstant

def load_seed
  DATA[:users] = YAML.safe_load_file('app/db/seeds/users_seeds.yml')
  DATA[:locations] = YAML.safe_load_file('app/db/seeds/locations_seeds.yml')
  DATA[:rooms] = YAML.safe_load_file('app/db/seeds/rooms_seeds.yml')
  DATA[:user_rooms] = YAML.safe_load_file('app/db/seeds/user_rooms_seeds.yml')
  DATA[:targets] = YAML.safe_load_file('app/db/seeds/targets_seeds.yml')
end
