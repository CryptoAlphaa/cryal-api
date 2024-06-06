# frozen_string_literal: true

module Cryal
    # Policy to determine if account can view a room details
    class RoomPolicy
      # Scope of room policies
      class AccountScope
        def initialize(current_account, target_account = nil)
          target_account ||= current_account
          @full_scope = all_rooms(target_account)
          @current_account = current_account
          @target_account = target_account
        end
  
        def viewable
          if @current_account == @target_account
            @full_scope
          else
            @full_scope.select do |room|
              inside_the_room?(room, @current_account)
            end
          end
        end
  
        private
  
        def all_rooms(account)
            account.user_rooms
        end
  
        def inside_the_room?(room, account)
            room.account_id == account.account_id
        end
      end
    end
  end