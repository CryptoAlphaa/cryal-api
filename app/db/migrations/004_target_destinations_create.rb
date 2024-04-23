require 'sequel'

Sequel.migration do
    change do
        create_table(:target_destinations) do
            primary_key :target_id
            Float :dest_lat, null: false
            Float :dest_long, null: false
            String :dest_address, null: true
            String :dest_name, null: true
        end
    end
end
