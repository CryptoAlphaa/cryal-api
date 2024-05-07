# frozen_string_literal: true

require 'json'
require 'sequel'

module Cryal
  # Waypoint class for managing Waypoint model
  class Waypoint < Sequel::Model
    many_to_one :plan, class: 'Cryal::Plan'

    plugin :uuid, field: :waypoint_id
    plugin :timestamps, update_on_create: true

    # mass asignment prevention
    plugin :whitelist_security
    set_allowed_columns :plan_id, :latitude, :longitude, :waypoint_address, :waypoint_name, :waypoint_number

    def to_json(*args) # rubocop:disable Metrics/MethodLength
      {
        waypoint_id:,
        plan_id:,
        waypoint_lat: latitude,
        waypoint_long: longitude,
        waypoint_address:,
        waypoint_name:,
        waypoint_number:,
        created_at:,
        updated_at:
      }.to_json(*args)
    end

    # Secure getters and setters
    def latitude
      SecureDB.decrypt(waypoint_lat_secure)
    end

    def latitude=(plaintext)
      self.waypoint_lat_secure = SecureDB.encrypt(plaintext)
    end

    def longitude
      SecureDB.decrypt(waypoint_long_secure)
    end

    def longitude=(plaintext)
      self.waypoint_long_secure = SecureDB.encrypt(plaintext)
    end
  end
end
