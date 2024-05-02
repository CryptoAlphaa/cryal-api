# frozen_string_literal: true

# This spec file is to test user model without the need to connect using the API
require_relative '../spec_helper'

describe 'User Model' do # rubocop:disable Metrics/BlockLength
  before do
    clear_db
    load_seed
  end

  describe 'HAPPY: Test User Model' do # rubocop:disable Metrics/BlockLength
    it 'should get all users and retrieve the correct information' do
      Cryal::User.create(DATA[:users][0])
      Cryal::User.create(DATA[:users][1])
      Cryal::User.create(DATA[:users][2])
      users = Cryal::User.all
      _(users.length).must_equal 3
      check_first_user = Cryal::User.all.first
      _(check_first_user[:username]).must_equal DATA[:users][0]['username']
    end

    it 'should get a single user' do
      user = Cryal::User.create(DATA[:users][1])
      user_id = user[:user_id]
      user = Cryal::User[user_id]
      _(user[:user_id]).wont_be_nil
    end

    it 'should create a new user' do
      user = Cryal::User.create(DATA[:users][1])
      _(user[:user_id]).wont_be_nil
    end

    it 'should encrypt email and passwords' do
      user = Cryal::User.create(DATA[:users][1])
      email = DATA[:users][1][:email]
      password = DATA[:users][1][:password]
      _(user[:email_secure]).wont_equal email
      _(user[:password_hash]).wont_equal password
    end
  end

  describe 'SAD: Test User Model' do
    it 'should return nil if user is not found' do
      user = Cryal::User.where(username: 'not_a_user').first
      _(user).must_be_nil
    end
  end
end
