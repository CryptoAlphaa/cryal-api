require 'sequel'

Sequel.migration do
    change do
        create_table(:tracking_sessions) do
            primary_key :session_id
            foreign_key :user_id, :users, null: false  # Reference to the user
            Float :dest_lat, null: true  # Optional destination latitude
            Float :dest_long, null: true  # Optional destination longitude
            String :dest_address, null: true
            String :destination_name, null: true  # Optional destination name
            TrueClass :active, default: true
        end
    end
end