# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:user_rooms) do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      foreign_key :room_id, :rooms, on_delete: :cascade
      Boolean :active, null: false
    end
  end
end
