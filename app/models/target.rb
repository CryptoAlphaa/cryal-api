# frozen_string_literal: true

require 'sequel'

module Cryal
  # Target model
  class Target < Sequel::Model
    one_to_many :room, optional: true

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
