# frozen_string_literal: true

require 'sequel'

module Cryal
  # User_Room model
  class User_Room < Sequel::Model # rubocop:disable Naming/ClassAndModuleCamelCase
    many_to_one :room, class: 'Cryal::Room'
    many_to_one :account, class: 'Cryal::Account'

    plugin :uuid, field: :account_id
    plugin :uuid, field: :room_id

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :active, :room_id, :account_id, :authority

    def to_json(options = {})
      JSON(
        {
          id:,
          room_id:,
          account_id:,
          active:,
          authority:
        },
        options
      )
    end
  end
end
