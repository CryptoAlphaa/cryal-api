# frozen_string_literal: true

require 'json'
require 'sequel'

module Cryal
    class Waypoint < Sequel::Model
        many_to_one :plan

        plugin :uuid, field: :waypoint_id
        plugin :timestamps, update_on_create: true

        # mass asignment prevention
        plugin :whitelist_security
        set_allowed_columns :latitude, :longitude, :waypoint_address, :waypoint_name

        def to_json(*args)
        {
            waypoint_id: waypoint_id,
            plan_id: plan_id,
            waypoint_lat: latitude,
            waypoint_long: longitude,
            waypoint_address: waypoint_address,
            waypoint_name: waypoint_name,
            waypoint_number: waypoint_number,
            created_at: created_at,
            updated_at: updated_at
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

        # Custom create function
        def self.create_waypoint(plan_id, lat, long, address, name)
            last_waypoint_number = Waypoint.where(plan_id: plan_id).max(:waypoint_number) || 0
            new_waypoint_number = last_waypoint_number + 1

            waypoint = self.new(
                plan_id: plan_id,
                waypoint_lat_secure: SecureDB.encrypt(lat),
                waypoint_long_secure: SecureDB.encrypt(long),
                waypoint_address: address,
                waypoint_name: name,
                waypoint_number: new_waypoint_number
            )
            waypoint.save
            waypoint
        end
    end
end