require 'sequel'

Sequel.migration do
    change do
        create_table(:user_sessions) do
            primary_key :id
            foreign_key :user_id, :users
            foreign_key :session_id, :sessions
            Boolean :active, null: false
        end
    end
end
