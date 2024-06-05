# frozen_string_literal: true

# Cryal Module
module Cryal
  module AccountService
    module Location
      # Fetch all locations belonging to a user
      class FetchAll
        class ForbiddenError < StandardError
          def message
            'You are not allowed access this accounts location'
          end
        end

        def self.call(requestor:)
            locations = requestor.locations
            policy = LocationPolicy.new(requestor, locations)
            policy.can_view? ? locations : raise(ForbiddenError)
        end
      end

      # Create location
      class Create
        extend Cryal
        def self.call(routing, json, account)
          not_found(routing, 'User not found') if account.nil?
          account.add_location(json)
        end
      end
    end

    module Room
      # Fetch all rooms where the user is.
      class FetchAll
        class ForbiddenError < StandardError
          def message
            'You are not allowed access all of the room'
          end
        end

        def self.call(requestor:)
          all_user_rooms = requestor.user_rooms
          all_rooms = all_user_rooms.map(&:room)
          policy = RoomPolicy.new(requestor, all_user_rooms)
          policy.can_view? ? all_rooms : raise(ForbiddenError)
        end
      end
      
      class FetchOne
        class ForbiddenError < StandardError
          def message
            'You are not allowed access this room!'
          end
        end

        class NotFoundError < StandardError
          def message
            'Room is not found!'
          end
        end

        def self.call(requestor_id, room_id)
          room = Cryal::Room.first(room_id:)
          return raise(NotFoundError) if room.nil?
          policy = RoomPolicy.new(requestor_id, room_id)
          policy.can_view? ? room : raise(ForbiddenError)
        end
      end

      # Create room
      class Create
        extend Cryal
        def self.call(routing, json, account_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          user.add_room(json)
        end
      end

      # Join room
      class Join
        extend Cryal

        class ForbiddenError < StandardError
          def message
            'You are not allowed to join this room!'
          end
        end

        def self.call(requestor:, join_request:)
          prepared_package = join_request
          policy = RoomPolicy.new(requestor, join_request)
          
          if policy.can_join?(join_request)
            prepared_package.delete('room_password')
            created_room = requestor.add_user_room(prepared_package)  
          else
            raise(ForbiddenError)
          end
            created_room
        end
      end
    end

    module Plans
      # Fetch plans
      class Fetch
        extend Cryal

        class ForbiddenError < StandardError
          def message
            'You are not allowed access this room!'
          end
        end

        class PlansNotFoundError < StandardError
          def message
            'Plans not found!'
          end
        end

        def self.call(requestor, room_id, plan_name=nil)
          user_room = Cryal::User_Room.first(account_id: requestor.account_id, room_id: room_id, active: true)
          return raise(ForbiddenError) if user_room.nil?
          policy = RoomPolicy.new(requestor, user_room)
          raise ForbiddenError unless policy.can_view?
          if plan_name.nil?
            return raise(PlansNotFoundError) if user_room.room.plans.nil?
            return user_room.room.plans
          else
            found = Cryal::Plan.first(room_id: room_id, plan_name: plan_name)
            found.nil? ? raise(PlansNotFoundError) : found
          end
        end
      end

      # Create plans
      class Create
        extend Cryal
        class ForbiddenError < StandardError
          def message
            'You are not allowed to create a plan in this room'
          end
        end

        class NotFoundError < StandardError
          def message
            'Room is not found'
          end
        end
        
        def self.call(requestor, room_id, plan_request)
          room = Cryal::Room.first(room_id: room_id)
          return raise(NotFoundError) if room.nil?
          user_room = Cryal::User_Room.first(account_id: requestor.account_id, room_id: room.room_id)
          return raise(ForbiddenError) if user_room.nil?
          policy = RoomPolicy.new(requestor, user_room)
          raise ForbiddenError unless policy.can_create_plan?
          room.add_plan(plan_request)
        end
      end
    end


          # not_found(routing, 'User not found') if user.nil?
          # room = Cryal::Room.first(room_name: plan['room_name'])
          # not_found(routing, 'Room not found') if room.nil?
          # user_room = Cryal::User_Room.first(account_id: user.account_id, room_id: room.room_id)
          # not_found(routing, 'User not in the room') if user_room.nil?
          # plan.delete('room_name')
          # room.add_plan(plan)
          # end

    # Waypoint service
    module Waypoint
      # Create waypoints
      class Create
        extend Cryal
        def self.call(routing, json, account_id, plan_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          plan = Cryal::Plan.first(plan_id:)
          not_found(routing, 'Plan not found') if plan.nil?
          room = Cryal::Room.first(room_id: plan.room_id)
          not_found(routing, 'Room not found') if room.nil?
          user_room = Cryal::User_Room.first(account_id: user.account_id, room_id: room.room_id, active: true)
          not_found(routing, 'User not in the room') if user_room.nil?
          last_waypoint_number = Cryal::Waypoint.where(plan_id: plan.plan_id).max(:waypoint_number) || 0
          new_waypoint_number = last_waypoint_number + 1
          # delete waypoint number field if it exists
          json.delete('waypoint_number')
          json[:waypoint_number] = new_waypoint_number
          plan.add_waypoint(json)
        end
      end

      # Fetch all waypoints
      class FetchAll
        extend Cryal
        def self.call(routing, account_id, plan_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          plan = Cryal::Plan.first(plan_id:)
          not_found(routing, 'Plan not found') if plan.nil?
          plan.waypoints
        end
      end

      # Fetch one waypoint
      class FetchOne
        extend Cryal
        def self.call(routing, account_id, plan_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          plan = Cryal::Plan.first(plan_id:)
          not_found(routing, 'Plan not found') if plan.nil?
          waypoint_number = routing.params['waypoint_number']
          waypoint = Cryal::Waypoint.first(plan_id: plan.plan_id, waypoint_number: waypoint_number)
          not_found(routing, 'Waypoint not found') if waypoint.nil?
          waypoint
        end
      end
    end

    # User service
    module Account
      # Create a new user
      class FetchAccount
        extend Cryal
        class ForbiddenError < StandardError
          def message
            'You are not allowed access this account'
          end
        end

        def self.call(requestor_id, account_id)
          account = Cryal::Account.first(account_id:)
          policy = AccountPolicy.new(requestor_id, account)
          policy.can_view? ? account: raise(ForbiddenError)
        end
        # def self.call(routing, account_id)
        #   user = Cryal::Account.first(account_id:)
        #   not_found(routing, 'User not found') if user.nil?
        #   user
        # end
      end
    end
  end
end
