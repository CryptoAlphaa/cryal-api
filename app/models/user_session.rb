require 'sequel'

module Cryal
    class User_Session < Sequel::Model
        one_to_one :session
        one_to_one :user
        
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