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
          p "User: #{user}"
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
      class FetchAll
        extend Cryal
        def self.call(routing, account_id)
          output = Cryal::User_Room.where(account_id:)
          output = output.all
          puts output
          not_found(routing, 'DB Error') if output.nil? # ga jalan
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

        # def self.create_package(room_json)
        #   room_id = room_json['room_id']
        #   room_password = room_json['room_password']
        #   authority = room_json['authority']
        #   package = {
        #     'room_id' => room_id,
        #     'room_password' => room_password,
        #     'active' => true
        #   }
        #   package['authority'] = authority if authority
        #   package
        # end

        def self.verify_room(room_id, room_password)
          room = Cryal::Room.first(room_id:)
          return false if room.nil?

          jsonify = JSON.parse(room.room_password_hash)
          salt = Base64.strict_decode64(jsonify['salt'])
          checksum = jsonify['hash']
          extend KeyStretch
          check = Base64.strict_encode64(password_hash(salt, room_password))
          check == checksum
        end

        def self.call(routing, room_json, account_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found', 404) if user.nil?
          prepared_package = room_json # create_package(room_json)
          # set_allowed_columns :active, :room_id, :account_id, :authority
          not_found(routing, 'Room not found or password is wrong', 404) unless verify_room(
            prepared_package['room_id'], prepared_package['room_password']
          )
          prepared_package.delete('room_password')
          user.add_user_room(prepared_package)
        end

        # def self.call(routing, json)
        #   user = Cryal::Account.first(username: json['username']) # user existed
        #   # raise error if user not found
        #   not_found(routing, @err_message, 403) if user.nil?
        #   # password
        #   jsonify = JSON.parse(user.password_hash)
        #   salt = Base64.strict_decode64(jsonify['salt'])
        #   checksum = jsonify['hash']
        #   extend KeyStretch
        #   check = Base64.strict_encode64(password_hash(salt, json['password']))
        #   not_found(routing, @err_message, 403) unless check == checksum
        #   { message: "Welcome back to NaviTogether, #{json['username']}!", data: user.to_json }
        # end
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
        def self.call(routing, plan, account_id)
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
        def self.call(routing, json, account_id, plan_id)
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
      class FetchOne
        extend Cryal
        def self.call(routing, account_id)
          user = Cryal::Account.first(account_id:)
          not_found(routing, 'User not found') if user.nil?
          user
        end
      end
    end
  end
end
