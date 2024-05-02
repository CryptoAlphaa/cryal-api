# frozen_string_literal: true

# This spec file is to test location model without the need to connect using the API
require_relative '../spec_helper'

describe 'Location Model' do
  before do
    clear_db
    load_seed

    # Because location has a foreign key dependency on user, we need to insert a user first.
    @user = Cryal::User.create(DATA[:users][0])
  end

  describe 'HAPPY: Test Location Model' do
    it 'should return the data correctly' do
      location = @user.add_location(DATA[:locations][0])
      DATA[:locations][0]
      _(location[:cur_address]).must_equal DATA[:locations][0]['cur_address']
      _(location[:cur_name]).must_equal DATA[:locations][0]['cur_name']
    end
  end

  describe 'SECURITY: Test Location Model' do
    it 'should not get the sensitve atributes' do
      location = @user.add_location(DATA[:locations][0])
      _(location[:cur_lat_secure]).wont_equal DATA[:locations][0]['latitude']
      _(location[:cur_long_secure]).wont_equal DATA[:locations][0]['longitude']
    end
  end
end
