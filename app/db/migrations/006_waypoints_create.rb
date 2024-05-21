# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:waypoints) do
      uuid :waypoint_id, primary_key: true
      foreign_key :plan_id, table: :plans, null: false, type: :uuid, on_delete: :cascade
      String :waypoint_lat_secure, null: false
      String :waypoint_long_secure, null: false
      String :waypoint_address
      String :waypoint_name
      Integer :waypoint_number, default: 1
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP

      # unique [:plan_id, :waypoint_number, :waypoint_name] # unique waypoint number for each plan
    end
  end
end
