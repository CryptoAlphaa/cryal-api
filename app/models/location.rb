# frozen_string_literal: true

require 'sequel'

module Cryal
  # Model for Location data
  class Location < Sequel::Model
    many_to_one :user

    plugin :timestamps, update_on_create: true

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :latitude, :longitude, :cur_address, :cur_name

    def to_json(*args)
      {
        location_id: location_id,
        user_id: user_id,
        latitude: self.cur_lat_secure,
        longitude: self.cur_long_secure,
        cur_address: cur_address,
        cur_name: cur_name,
        created_at: created_at
      }.to_json(*args)
    end

    # Secure getters and setters
    def latitude
      SecureDB.decrypt(cur_lat_secure)
    end

    def latitude=(plaintext)
      self.cur_lat_secure = SecureDB.encrypt(plaintext)
    end

    def longitude
      SecureDB.decrypt(cur_long_secure)
    end

    def longitude=(plaintext)
      self.cur_long_secure = SecureDB.encrypt(plaintext)
    end

    # Custom create function
    def self.create_location(user_id, lat, long, address, name)
      location = self.new(
        user_id: user_id,
        cur_lat_secure: SecureDB.encrypt(lat),
        cur_long_secure: SecureDB.encrypt(long),
        cur_address: address,
        cur_name: name
      )
      location.save
      location
    end
  end
end
