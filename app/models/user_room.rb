# frozen_string_literal: true

require 'sequel'

module Cryal
  # User_Room model
  class User_Room < Sequel::Model # rubocop:disable Naming/ClassAndModuleCamelCase
    many_to_one :room
    many_to_one :user

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :active, :room_id

    def to_json(*args)
      {
        id: id,
        room_id: room_id,
        user_id: user_id,
        active: active
      }.to_json(*args)
    end
  end
end
