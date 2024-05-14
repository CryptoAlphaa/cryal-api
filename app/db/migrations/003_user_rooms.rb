# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:user_rooms) do
      primary_key :id
      foreign_key :account_id, :accounts, null: false, on_delete: :cascade
      foreign_key :room_id, :rooms, on_delete: :cascade
      Boolean :active
      String :authority
    end
  end
end
