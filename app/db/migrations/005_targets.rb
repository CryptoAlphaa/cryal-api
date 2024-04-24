require 'sequel'

Sequel.migration do
    change do
      create_table(:targets) do
        primary_key :id
        Float :dest_lat
        Float :dest_long
        String :dest_address
        String :dest_name
      end
    end
  end