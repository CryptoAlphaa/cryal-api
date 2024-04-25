# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :user_id, serial: true
      String :username, null: false
      String :email, null: false
      String :password_hash, null: false
    end
  end
end
