require 'sequel'

Sequel.migration do
    change do
        create_table(:locations) do
        primary_key :location_id
        foreign_key :user_id, :users, null: false  # Reference to the user
        Float :cur_lat, null: false
        Float :cur_long, null: false
        String :current_address, null: true
        String :current_name, null: true
        DateTime :timestamp, default: Sequel::CURRENT_TIMESTAMP
        foreign_key :session_id, :tracking_sessions, null: true # Reference to the associated tracking session (optional)
        end
    end
end