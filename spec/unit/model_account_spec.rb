# frozen_string_literal: true

# This spec file is to test user model without the need to connect using the API
require_relative '../spec_helper'

describe 'Account Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
  end

  describe 'HAPPY: Test Account Model' do # rubocop:disable Metrics/BlockLength
    it 'should get all users and retrieve the correct information' do
      Cryal::Account.create(DATA[:accounts][0])
      Cryal::Account.create(DATA[:accounts][1])
      Cryal::Account.create(DATA[:accounts][2])
      users = Cryal::Account.all
      _(users.length).must_equal 3
      check_first_user = Cryal::Account.all.first
      _(check_first_user[:username]).must_equal DATA[:accounts][0]['username']
    end

    it 'should get a single user' do
      user = Cryal::Account.create(DATA[:accounts][1])
      account_id = user[:account_id]
      user = Cryal::Account[account_id]
      _(user[:account_id]).wont_be_nil
    end

    it 'should create a new user' do
      user = Cryal::Account.create(DATA[:accounts][1])
      _(user[:account_id]).wont_be_nil
    end

    it 'should encrypt email and passwords' do
      user = Cryal::Account.create(DATA[:accounts][1])
      email = DATA[:accounts][1][:email]
      password = DATA[:accounts][1][:password]
      _(user[:email_secure]).wont_equal email
      _(user[:password_hash]).wont_equal password
    end
  end

  describe 'SAD: Test User Model' do
    it 'should return nil if user is not found' do
      user = Cryal::Account.where(username: 'not_a_user').first
      _(user).must_be_nil
    end
  end
end
