# frozen_string_literal: true

require 'json'
require 'sequel'

module Cryal
  # Model for Location data
  class Plan < Sequel::Model
    many_to_one :room, class: 'Cryal::Room'
    one_to_many :waypoints, class: 'Cryal::Waypoint', on_delete: :cascade

    plugin :uuid, field: :plan_id
    # plugin :uuid, field: :room_id
    plugin :timestamps, update_on_create: true

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :plan_name, :plan_description

    # Secure getters and setters
    def plan_description
      SecureDB.decrypt(plan_description_secure)
    end

    def plan_description=(plaintext)
      self.plan_description_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(options = {})
      JSON(
        {
          plan_id:,
          room_id:,
          plan_name:,
          plan_description: plan_description_secure,
          created_at:,
          updated_at:
        },
        options
      )
    end
  end
end
