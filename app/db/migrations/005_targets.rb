# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:targets) do
      primary_key :target_id
      Float :dest_lat, null: false
      Float :dest_long, null: false
      String :dest_address
      String :dest_name
    end
  end
end
