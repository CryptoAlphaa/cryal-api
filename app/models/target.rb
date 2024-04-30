# frozen_string_literal: true

require 'sequel'

module Cryal
  # Target model
  class Target < Sequel::Model
    one_to_many :room, optional: true


    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :dest_lat, :dest_long, :dest_address, :dest_name

    def to_json(*args)
      {
        target_id:,
        dest_lat:,
        dest_long:,
        dest_address:,
        dest_name:
      }.to_json(*args)
    end
  end
end
