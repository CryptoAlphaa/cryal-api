# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:users) do
      uuid :user_id, primary_key: true
      String :username, null: false
      String :email_secure, null: false
      String :password_hash, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
