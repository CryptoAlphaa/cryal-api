# frozen_string_literal: true

module Cryal
  # Policy to determine if an account can view a particular project
  class RoomPolicy
    def initialize(account, user_room, auth_scope = nil)
      @account = account
      @user_room = user_room
      @auth_scope = auth_scope
    end

    def can_view?
      member? && can_read?
    end

    def can_edit_room_info?
      admin? && can_write?
    end

    def can_delete_room?
      admin? && can_write?
    end

    def can_remove_member?
      admin? && can_write?
    end

    def can_leave?
      member? && can_write?
    end

    def can_edit_authority?
      admin? && can_write?
    end

    def can_create_plan?
      member? && can_write?
    end

    def can_edit_plan?
      member? && can_write?
    end

    def can_delete_plan?
      member? && can_write?
    end

    def can_create_waypoint?
      member? && can_write?
    end

    def can_edit_waypoint?
      member? && can_write?
    end

    def can_view_waypoint?
      member? && can_read?
    end

    def can_join?(join_request)
      verify_request(join_request) && can_write?
    end

    def summary # rubocop:disable Metrics/MethodLength
      {
        can_view: can_view?,
        can_edit_room_info: can_edit?,
        can_delete_room: can_delete_room?,
        can_remove_member: can_remove_member?,
        can_edit_authority: can_edit_authority?,
        can_leave: can_leave?,
        can_create_plan: can_create_plan?,
        can_edit_plan: can_edit_plan?,
        can_delete_plan: can_delete_plan?,
        member: member?,
        admin: admin?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('rooms') : false
    end
    
    def can_write?
      @auth_scope ? @auth_scope.can_write?('rooms') : false
    end

    def member?
      # p "Authorized account: #{@account}"
      # p "user_room: #{@user_room}"
      # p "account from user_room: #{@user_room.account}"
      return @user_room.account = @account if @user_room.instance_of?(Cryal::User_Room)

      @user_room.select do |exist|
        exist.active == true
      end
    end

    def admin?
      @user_room['authority'] == 'admin'
    end

    def verify_request(join_request)
      room = Cryal::Room.first(room_id: join_request['room_id'])
      return false if room.nil?

      jsonify = JSON.parse(room.room_password_hash)
      salt = Base64.strict_decode64(jsonify['salt'])
      checksum = jsonify['hash']
      extend KeyStretch
      check = Base64.strict_encode64(password_hash(salt, join_request['room_password']))
      check == checksum
    end
  end
end
