# require 'sequel'

# module Cryal
#     class TrackSession < Sequel::Model
#         many_to_one :user
#         one_to_many :locations

#         def to_json(*args)
#             {
#                 session_id: session_id,
#                 user_id: user_id,
#                 dest_lat: dest_lat,
#                 dest_long: dest_long,
#                 dest_address: dest_address,
#                 destination_name: destination_name,
#                 active: active
#             }.to_json(*args)
#         end
#     end
# end
