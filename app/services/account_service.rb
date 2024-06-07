# frozen_string_literal: true

# Cryal Module
module Cryal
  module AccountService
    module Location
      # Fetch all locations belonging to a user
      class FetchAll
        # Error class for forbidden access
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
        # Error class for forbidden access
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

      # Fetch one room
      class FetchOne
        # Error class for forbidden access
        class ForbiddenError < StandardError
          def message
            'You are not allowed access this room!'
          end
        end

        # Error class for room not found
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
        # Error class for forbidden access
        class ForbiddenError < StandardError
          def message
            'You are not allowed to create a room!'
          end
        end

        def self.call(requestor, room_request)
          requestor.add_room(room_request)
        end
      end

      # Join room
      class Join
        extend Cryal
        # Error class for forbidden access
        class ForbiddenError < StandardError
          def message
            'You are not allowed to join this room!'
          end
        end

        # Error class for room not found
        class NotFoundError < StandardError
          def message
            'Room is not found!'
          end
        end

        def self.call(requestor, join_request)
          prepared_package = join_request
          policy = RoomPolicy.new(requestor, join_request)
          raise(ForbiddenError) unless policy.can_join?(join_request)

          prepared_package.delete('room_password')
          requestor.add_user_room(prepared_package)
        end
      end
    end

    module Plans
      # Fetch plans
      class Fetch
        extend Cryal
        # Error class for forbidden access
        class ForbiddenError < StandardError
          def message
            'You are not allowed access this room!'
          end
        end

        # Error class for plans not found
        class PlansNotFoundError < StandardError
          def message
            'Plans not found!'
          end
        end

        def self.call(requestor, room_id, plan_name = nil) # rubocop:disable Metrics/AbcSize
          user_room = Cryal::User_Room.first(account_id: requestor.account_id, room_id:, active: true)
          return raise(ForbiddenError) if user_room.nil?

          policy = RoomPolicy.new(requestor, user_room)
          raise ForbiddenError unless policy.can_view?

          if plan_name.nil?
            return raise(PlansNotFoundError) if user_room.room.plans.nil?

            user_room.room.plans
          else
            found = Cryal::Plan.first(room_id:, plan_name:)
            found.nil? ? raise(PlansNotFoundError) : found
          end
        end
      end

      # Create plans
      class Create
        extend Cryal
        # Error class for forbidden access
        class ForbiddenError < StandardError
          def message
            'You are not allowed to create a plan in this room'
          end
        end

        # Error class for room not found
        class NotFoundError < StandardError
          def message
            'Room is not found'
          end
        end

        def self.call(requestor, room_id, plan_request)
          room = Cryal::Room.first(room_id:)
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
        # Error class for forbidden access
        class ForbiddenError < StandardError
          def message
            'You are not allowed to create a waypoint in this plan!'
          end
        end

        # Error class for plan not found
        class NotFoundError < StandardError
          def message
            'Plan is not found!'
          end
        end

        def self.call(requestor, room_id, plan_id, waypoint_request) # rubocop:disable Metrics/AbcSize
          plan = Cryal::Plan.first(plan_id:)
          return raise(NotFoundError) if plan.nil?

          user_room = Cryal::User_Room.first(account_id: requestor.account_id, room_id:)
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
        # Error class for forbidden access
        class ForbiddenError < StandardError
          def message
            'You are not allowed to create a waypoint in this plan!'
          end
        end

        # Error class for plan not found
        class NotFoundError < StandardError
          def message
            'Plan is not found!'
          end
        end

        def self.call(requestor, room_id, plan_id, waypoint_number = nil)
          plan = Cryal::Plan.first(plan_id:)
          return raise(NotFoundError) if plan.nil?

          user_room = Cryal::User_Room.first(account_id: requestor.account_id, room_id:)
          return raise(ForbiddenError) if user_room.nil?

          policy = RoomPolicy.new(requestor, user_room)
          raise ForbiddenError unless policy.can_view_waypoint?
          return plan.waypoints if waypoint_number.nil?

          found = Cryal::Waypoint.first(plan_id:, waypoint_number:)
          found.nil? ? raise(NotFoundError) : found
        end
      end
    end

    # User service
    module Account
      # Create a new user
      class FetchAccount
        extend Cryal
        # Error class for forbidden access
        class ForbiddenError < StandardError
          def message
            'You are not allowed access this account'
          end
        end

        def self.call(requestor_id, account_id)
          account = Cryal::Account.first(account_id:)
          policy = AccountPolicy.new(requestor_id, account)
          policy.can_view? ? account : raise(ForbiddenError)
        end
      end
    end
  end
end
