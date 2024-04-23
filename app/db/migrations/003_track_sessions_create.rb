require 'sequel'

Sequel.migration do
    change do
        create_table(:tracking_sessions) do
            primary_key :session_id
            foreign_key :target_id, :target_destinations, null: false
            String :password_session_hash, null: false
            DateTime :created_time, default: Sequel::CURRENT_TIMESTAMP
        end
    end
end
