# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:rooms) do
      uuid :room_id, primary_key: true
      foreign_key :account_id, :accounts, null: false, type: :uuid, on_delete: :cascade
      String :room_name, null: false
      String :room_description_secure
      String :room_password_hash # must be hashed!
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
