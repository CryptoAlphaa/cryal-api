# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:locations) do
      primary_key :location_id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      Float :cur_lat, null: false
      Float :cur_long, null: false
      String :cur_address
      String :cur_name
      DateTime :timestamp, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
