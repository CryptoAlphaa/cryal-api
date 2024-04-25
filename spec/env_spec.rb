# frozen_string_literal: true

require_relative 'init_spec'

describe 'Do not expose secret credential' do
  it 'should not find database url' do
    _(Cryal::Api.config.DATABASE_URL).must_be_nil
  end
end
