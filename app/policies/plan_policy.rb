# Policy to determine if account can view a plan resource
# A user can view a plan, if the user is within a room that has that plan
# To know if a user is within a room, we need to check if the user has a userroom with that room id where the plan is.

class PlanPolicy
    def initialize(account, plan)
      @account = account
      @plan = plan
    end

    def can_view?
        account_has_access_to_plan?
    end

    def can_edit?
        account_has_access_to_plan?
    end

    def can_add_waypoint?
        account_has_access_to_plan?
    end

    def can_delete_waypoint?
        account_has_access_to_plan?
    end

    def can_update_waypoint?
        account_has_access_to_plan?
    end

    def summary
    {
        can_view: can_view?,
        can_edit: can_edit?,
        can_add_waypoint: can_add_waypoint?,
        can_delete_waypoint: can_delete_waypoint?,
        can_update_waypoint: can_update_waypoint?
    }
    end

    private

    def account_has_access_to_plan?
        @plan.room.user_rooms.account == @account
    end
end