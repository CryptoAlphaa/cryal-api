require 'sequel'

module Cryal
    class Users < Sequel::Model
        one_to_many :routes
        one_to_many :friends
        plugin :validation_helpers
        plugin :association_dependencies, routes: :destroy, friends: :destroy

        def to_json(*args)
            {
                user_id: user_id,
                username: username,
                email: email,
                password_hash: password_hash
            }.to_json(*args)
        end
    end
end