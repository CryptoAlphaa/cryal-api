module Cryal
  # Policy to determine if an account can view a particular project
  class RoomPolicy
    def initialize(account, user_room)
      @account = account
      @user_room = user_room
    end

    def can_view?
      is_admin?
    end

    # duplication is ok!
    def can_edit?
      is_admin?
    end

    def can_delete?
      is_admin?
    end

    def can_leave?
      account_is_collaborator?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        is_member: is_member?,
        is_admin: is_admin?
      }
    end

    private

    def is_member?
      @user_room["active"] == true
    end

    def is_admin?
      @user_room["authority"] == 'admin'
    end

  end
end
