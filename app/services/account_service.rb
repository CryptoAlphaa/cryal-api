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
          policy = RoomPolicy.new(requestor_id, room.user_rooms)
          policy.can_view? ? room : raise(ForbiddenError)
        end
      end

      # Create room
      class Create
        extend Cryal
        class ForbiddenError < StandardError
          def message
            'You are not allowed to create a room!'
          end
        end

        def self.call(requestor, room_request)
          room = requestor.add_room(room_request)
          room
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

        class NotFoundError < StandardError
          def message
            'Room is not found!'
          end
        end

        def self.call(requestor, join_request)
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
            return raise(PlansNotFoundError) if user_room.room.plans.nil? # if looking for a specific plan and it's not found
            return user_room.room.plans # if looking for all plans
          else
            found = Cryal::Plan.first(room_id: room_id, plan_name: plan_name) # if looking for a specific plan
            raise PlansNotFoundError if found.nil?
            # when we find the plan, we must get all users latest location, and the plan's waypoints
            data = { plan: found, waypoints: found.waypoints }
            location_data = []
            all_users = Cryal::User_Room.where(room_id: room_id, active: true)
            all_users.each do |acc|
              location = acc.account.locations.last
              location_data << { username: acc.account.username, location: location }
            end
            data[:user_locations] = location_data
            data
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

    # Waypoint service
    module Waypoint
      # Create waypoints
      class Create
        extend Cryal
        class ForbiddenError < StandardError
          def message
            'You are not allowed to create a waypoint in this plan!'
          end
        end

        class NotFoundError < StandardError
          def message
            'Plan is not found!'
          end
        end

        def self.call(requestor, room_id, plan_id, waypoint_request)
          plan = Cryal::Plan.first(plan_id: plan_id)
          return raise(NotFoundError) if plan.nil?
          user_room = Cryal::User_Room.first(account_id: requestor.account_id, room_id: room_id)
          return raise(ForbiddenError) if user_room.nil?
          policy = RoomPolicy.new(requestor, user_room)
          raise ForbiddenError unless policy.can_create_waypoint?
          last_waypoint_number = Cryal::Waypoint.where(plan_id: plan.plan_id).max(:waypoint_number) || 0
          waypoint_request[:waypoint_number] = last_waypoint_number + 1
          plan.add_waypoint(waypoint_request)
        end
      end

      # Fetch all waypoints
      class Fetch
        extend Cryal
        class ForbiddenError < StandardError
          def message
            'You are not allowed to create a waypoint in this plan!'
          end
        end

        class NotFoundError < StandardError
          def message
            'Plan is not found!'
          end
        end

        def self.call(requestor, room_id, plan_id, waypoint_number=nil)
          plan = Cryal::Plan.first(plan_id: plan_id)
          return raise(NotFoundError) if plan.nil?
          user_room = Cryal::User_Room.first(account_id: requestor.account_id, room_id: room_id)
          return raise(ForbiddenError) if user_room.nil?
          policy = RoomPolicy.new(requestor, user_room)
          raise ForbiddenError unless  policy.can_view_waypoint?
          if waypoint_number.nil?
            return plan.waypoints
          else
            found = Cryal::Waypoint.first(plan_id: plan_id, waypoint_number: waypoint_number)
            found.nil? ? raise(NotFoundError) : found
          end
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
      end
    end
  end
end
