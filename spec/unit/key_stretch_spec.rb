# frozen_string_literal: true

# This spec file is used to test the key_stretch module
require_relative '../spec_helper'

describe 'KeyStretch Module' do
  include KeyStretch

  before do
    @salt = new_salt
  end

  describe 'HAPPY: KeyStretch Module' do
    it 'should return a salt' do
      _(@salt).wont_be_nil
    end

    it 'should return a hashed password' do
      password = 'password'
      hashed_password = password_hash(@salt, password)
      _(hashed_password).wont_be_nil
      _(hashed_password).wont_equal password
    end
  end
end
