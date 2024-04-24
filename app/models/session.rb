require 'sequel'

module Cryal
    class Session < Sequel::Model
        many_to_one :target
        one_to_one :user_session

        def to_json(*args)
            {
                session_id: session_id,
                target_id: target_id,
                password_session_hash: password_session_hash,
                created_time: created_time
            }.to_json(*args)
        end
    end
end
