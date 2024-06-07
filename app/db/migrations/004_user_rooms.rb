# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:user_rooms) do
      primary_key :id
      foreign_key :account_id, :accounts, null: false, type: :uuid, on_delete: :cascade
      foreign_key :room_id, :rooms, type: :uuid, on_delete: :cascade
      Boolean :active
      String :authority, default: 'member'

      unique %i[account_id room_id]
    end
  end
end
