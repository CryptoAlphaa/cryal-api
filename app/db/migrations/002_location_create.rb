# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:locations) do
      primary_key :location_id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      String :cur_lat_secure, null: false
      String :cur_long_secure, null: false
      String :cur_address
      String :cur_name
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
