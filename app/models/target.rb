require 'sequel'

module Cryal
    class Target < Sequel::Model
        one_to_many :session, optional: true

        def to_json(*args)
        {
            target_id: target_id,
            dest_lat: dest_lat,
            dest_long: dest_long,
            dest_address: dest_address,
            dest_name: dest_name
        }.to_json(*args)
        end
    end
end