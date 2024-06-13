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

        def self.call(auth_info)
            locations = auth_info[:account].locations
            policy = LocationPolicy.new(auth_info[:account], locations, auth_info[:scope])
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
          # all_user_rooms = requestor.user_rooms
          # all_rooms = all_user_rooms.map(&:room)
          # policy = RoomPolicy.new(requestor, all_user_rooms)
          # policy.can_view? ? all_rooms : raise(ForbiddenError)
          rooms = RoomPolicy::AccountScope.new(requestor).viewable
          rooms
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

        def self.call(requestor, room_id)
          room = Cryal::Room.first(room_id:)
          return raise(NotFoundError) if room.nil?
          policy = RoomPolicy.new(requestor[:account], room.user_rooms, requestor[:scope])
          policy.can_view? ? room : raise(ForbiddenError)
          accounts = room.user_rooms.map do |user_room|
            user = user_room.account
            { user_id: user.account_id, username: user.username }
          end
          { rooms: room, accounts: accounts, plans: room.plans}
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
          raise ForbiddenError unless requestor[:scope].can_write?('rooms')
          requestor[:account].add_room(room_request)
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
          policy = RoomPolicy.new(requestor[:account], join_request, requestor[:scope])
          raise ForbiddenError unless policy.can_join?(join_request)
          join_request.delete('room_password')
          requestor[:account].add_user_room(join_request)
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
          user_room = Cryal::User_Room.first(account_id: requestor[:account].account_id, room_id: room_id, active: true)
          return raise(ForbiddenError) if user_room.nil?
          policy = RoomPolicy.new(requestor[:account], user_room, requestor[:scope])
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
          user_room = Cryal::User_Room.first(account_id: requestor[:account].account_id, room_id: room.room_id)
          return raise(ForbiddenError) if user_room.nil?
          policy = RoomPolicy.new(requestor[:account], user_room, requestor[:scope])
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
          user_room = Cryal::User_Room.first(account_id: requestor[:account].account_id, room_id: room_id)
          return raise(ForbiddenError) if user_room.nil?
          policy = RoomPolicy.new(requestor[:account], user_room, requestor[:scope])
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
          user_room = Cryal::User_Room.first(account_id: requestor[:account].account_id, room_id: room_id)
          return raise(ForbiddenError) if user_room.nil?
          policy = RoomPolicy.new(requestor[:account], user_room, requestor[:scope])
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

        def self.call(requestor_id, account_username)
          account = Cryal::Account.first(username: account_username)
          policy = AccountPolicy.new(requestor_id, account)
          policy.can_view? ? account: raise(ForbiddenError)
          account_and_token(account, AuthScope.new(AuthScope::READ_ONLY))
        end

        def self.account_and_token(account, auth_scope)
          {
            type: 'authorized_account',
            attributes: {
              account: account,
              auth_token: AuthToken.create(account, auth_scope)
            }
          }
        end
      end
    end
  end
end
