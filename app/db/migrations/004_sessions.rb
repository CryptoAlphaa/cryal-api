require 'sequel'

Sequel.migration do
    change do
      create_table(:sessions) do
        primary_key :id
        foreign_key :target_id, :targets
        String :password, null: false
      end
    end
  end