# frozen_string_literal: true

require 'sequel'

module Cryal
  # User_Room model
  class User_Room < Sequel::Model # rubocop:disable Naming/ClassAndModuleCamelCase
    many_to_one :room
    many_to_one :user

    plugin :uuid, field: :user_id
    plugin :uuid, field: :room_id

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :active, :room_id, :user_id

    def to_json(*args)
      {
        id:,
        room_id:,
        user_id:,
        active:
      }.to_json(*args)
    end
  end
end
