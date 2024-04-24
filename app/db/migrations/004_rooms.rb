require 'sequel'

Sequel.migration do
    change do
      create_table(:rooms) do
        primary_key :id
        foreign_key :target_id, :targets
        foreign_key :created_by, :users, null: false
        String :room_name, null: false
        String :room_password
        DateTime :timestamp, default: Sequel::CURRENT_TIMESTAMP
      end
    end
  end