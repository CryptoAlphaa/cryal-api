# # frozen_string_literal: true

# module Cryal
#     # Policy to determine if account can view plan details
#     class PlanPolicy
#       # Scope of room policies
#       class AccountScope
#         def initialize(current_account, target_account = nil)
#             target_account ||= current_account
#             @full_scope = all_plans(target_account)
#             @current_account = current_account
#             @target_account = target_account
#         end

#         def viewable
#             if @current_account == @target_account
#                 @full_scope
#             else
#                 @full_scope.select do |plan|
#                     inside_the_room?(plan, @current_account)
#                 end
#             end
#         end

#         private

#         def all_plans(account)
#             account.user_rooms.room.plans
#         end

#         def inside_the_room?(plan, account)
#             plan.room.user_rooms.account == account
#         end
#     end
# end