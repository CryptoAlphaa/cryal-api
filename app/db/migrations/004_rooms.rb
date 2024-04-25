# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:rooms) do
      primary_key :room_id
      foreign_key :target_id, :targets
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      String :room_name, null: false
      String :room_password
      DateTime :timestamp, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
