# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

# require 'minitest/autorun'
# require 'minitest/rg'
require 'yaml'
require 'fileutils'
require 'sequel'

require_relative 'test_load_all'

# Data takes from db file.

# clear each table
# clear in order because of foreign key constraints, a -> b means a gives foreign key to b
# structure: locations <- users -> user_rooms <-> rooms <- targets

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

# test function to load everything into the database
def verify_load_all
  clear_db
  puts 'Loading all data into the database'

  app.DB[:users].insert(DATA[:users].first)
  app.DB[:locations].insert(DATA[:locations].first)
  app.DB[:targets].insert(DATA[:targets].first)
  app.DB[:rooms].insert(DATA[:rooms].first)
  app.DB[:user_rooms].insert(DATA[:user_rooms].first)

  puts 'Data loaded'
  clear_db
  puts 'Data cleared'
end
