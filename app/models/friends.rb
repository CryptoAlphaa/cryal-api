require 'sequel'

module Cryal
    class Friends < Sequel::Model
        many_to_one :user
        many_to_one :friend, class: :User
        plugin :validation_helpers

        def validate
            super
            validates_presence [:user_id, :friend_id, :status]
        end
    end
end