# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require 'fileutils'
require 'sequel'

require_relative 'test_load_all'

def clear_db
  Cryal::Account.dataset.destroy
  Cryal::Room.dataset.destroy
end

DATA = {} # rubocop:disable Style/MutableConstant

def load_seed
  DATA[:accounts] = YAML.safe_load_file('app/db/seeds/accounts_seeds.yml')
  DATA[:locations] = YAML.safe_load_file('app/db/seeds/locations_seeds.yml')
  DATA[:rooms] = YAML.safe_load_file('app/db/seeds/rooms_seeds.yml')
  DATA[:user_rooms] = YAML.safe_load_file('app/db/seeds/user_rooms_seeds.yml')
  DATA[:plans] = YAML.safe_load_file('app/db/seeds/plans_seeds.yml')
  DATA[:waypoints] = YAML.safe_load_file('app/db/seeds/waypoints_seeds.yml')
end

## SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load(
  File.read('spec/fixtures/github_token_response.yml')
)
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
SSO_ACCOUNT = YAML.load(File.read('spec/fixtures/sso_account.yml'))