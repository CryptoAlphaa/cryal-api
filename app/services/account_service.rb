# frozen_string_literal: true

# Cryal Module
module Cryal
  module AccountService
    module Location
      # Fetch all locations belonging to a user
      class FetchAll
        extend Cryal
        def self.call(routing, account_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          user.locations
        end
      end

      # Create location
      class Create
        extend Cryal
        def self.call(routing, json, account_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          user.add_location(json)
        end
      end
    end

    module Room
      # Fetch all rooms where the user is.
      class FetchOne
        extend Cryal
        def self.call(routing, account_id)
          output = { data: Cryal::Account.first(account_id:).rooms }
          not_found(routing, 'DB Error') if output.nil?
          output
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
        def self.call(routing, room_id, account_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          user.add_user_room(room_id)
        end
      end
    end

    module Plans
      # Fetch plans
      class FetchOne
        extend Cryal
        def self.call(routing, account_id) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          search = routing.params['room_name']
          room = Cryal::Room.first(room_name: search)
          not_found(routing, 'Room not found') if room.nil?
          user_room = Cryal::User_Room.first(account_id: user.account_id, room_id: room.room_id)
          not_found(routing, 'User not in the room') if user_room.nil?
          all_plans = room.plans
          # Extract only the plan_name and plan_description
          output = []
          all_plans.each do |plan|
            output.push(plan.to_json)
          end
          all_plans
        end
      end

      # Create plans
      class Create
        extend Cryal
        def self.call(routing, plan, account_id) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          room = Cryal::Room.first(room_name: plan['room_name'])
          not_found(routing, 'Room not found') if room.nil?
          user_room = Cryal::User_Room.first(account_id: user.account_id, room_id: room.room_id)
          not_found(routing, 'User not in the room') if user_room.nil?
          plan.delete('room_name')
          room.add_plan(plan)
        end
      end
    end

    # Waypoint service
    module Waypoint
      # Create waypoints
      class Create
        extend Cryal
        def self.call(routing, json, account_id, plan_id) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          plan = Cryal::Plan.first(plan_id:)
          not_found(routing, 'Plan not found') if plan.nil?
          last_waypoint_number = Cryal::Waypoint.where(plan_id: plan.plan_id).max(:waypoint_number) || 0
          new_waypoint_number = last_waypoint_number + 1
          # delete waypoint number field if it exists
          json.delete('waypoint_number')
          json[:waypoint_number] = new_waypoint_number
          plan.add_waypoint(json)
        end
      end

      # Fetch waypoints
      class FetchOne
        extend Cryal
        def self.call(routing, account_id, plan_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          plan = Cryal::Plan.first(plan_id:)
          not_found(routing, 'Plan not found') if plan.nil?
          plan.waypoints
        end
      end
    end

   # User service
   module Account
        # Create a new user
        class FetchOne extend Cryal
            def self.call(routing, account_id)
                user = Cryal::Account.first(account_id:)
                not_found(routing, 'User not found') if user.nil?
                user
            end
        end
   end
  end
end