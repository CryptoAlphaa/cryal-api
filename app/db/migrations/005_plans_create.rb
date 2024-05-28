# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:plans) do
      uuid :plan_id, primary_key: true
      foreign_key :room_id, table: :rooms, type: :uuid, on_delete: :cascade

      String :plan_name, null: false
      String :plan_description_secure # encrypted plan description

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP

      # unique [:room_id, :plan_name]
    end
  end
end
