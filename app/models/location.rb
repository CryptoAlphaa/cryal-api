# frozen_string_literal: true

require 'sequel'

module Cryal
  # Model for Location data
  class Location < Sequel::Model
    many_to_one :user

    def to_json(*args)
      {
        location_id:,
        user_id:,
        cur_lat:,
        cur_long:,
        cur_address:,
        cur_name:,
        timestamp:
      }.to_json(*args)
    end
  end
end
