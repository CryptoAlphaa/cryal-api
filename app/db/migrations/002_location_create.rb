# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:locations) do
      primary_key :location_id
      foreign_key :account_id, :accounts, null: false, type: :uuid, on_delete: :cascade
      String :cur_lat_secure, null: false
      String :cur_long_secure, null: false
      String :cur_address
      String :cur_name
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # change do
    #   alter_table(:locations) do
    #     drop_foreign_key :account_id
    #     add_foreign_key :account_id, :accounts, type: :uuid, key: :account_id
    #   end
    # end

  end
end
