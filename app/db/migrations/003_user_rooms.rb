require 'sequel'

Sequel.migration do
    change do
        create_table(:user_rooms) do
            primary_key :id
            foreign_key :user_id, :users, null: false
            foreign_key :room_id, :rooms
            Boolean :active, null: false
        end
    end
end
