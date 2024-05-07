Sequel.seed(:development) do
  def run
    create_users
    add_locations
    create_rooms
    create_user_rooms
    create_plans
    create_waypoints
  end
end

# load all yaml seeds
require 'yaml'
DIR = File.dirname(__FILE__)
USER_INFO = YAML.load_file("#{DIR}/users_seeds.yml")
LOCATION_INFO = YAML.load_file("#{DIR}/locations_seeds.yml")
ROOM_INFO = YAML.load_file("#{DIR}/rooms_seeds.yml")
USER_ROOM_INFO = YAML.load_file("#{DIR}/user_rooms_seeds.yml")
PLAN_INFO = YAML.load_file("#{DIR}/plans_seeds.yml")
WAYPOINT_INFO = YAML.load_file("#{DIR}/waypoints_seeds.yml")


def create_users
  USER_INFO.each do |data|
    Cryal::User.create(data)
  end
end

def add_locations
  users = Cryal::User.all
  users.each_with_index do |user, index|
    user.add_location(LOCATION_INFO[index])
  end
end

def create_rooms
  users = Cryal::User.all
  users.each_with_index do |user, index|
    user.add_room(ROOM_INFO[index])
    break if index == 3
  end
end

def create_user_rooms
  users = Cryal::User.all
  rooms = Cryal::Room.all
  room_ids = []
  rooms.each_with_index do |room, index|
    room_ids.push(room.room_id)
  end
  users.each_with_index do |user, index|
    user_room_info = USER_ROOM_INFO[index % 4] || { active: true }
    user_room_packet = {
      'active' => user_room_info["active"],
      'room_id' => room_ids[index % 4]
    }
    user.add_user_room(user_room_packet)
  end
end

def create_plans
  rooms = Cryal::Room.all
  rooms.each_with_index do |room, index|
    room.add_plan(PLAN_INFO[index % 4])
    break if index == 3
  end
end

def create_waypoints
  plans = Cryal::Plan.all
  plans.each_with_index do |plan, index|
    waypoint_data = WAYPOINT_INFO[index]
    waypoint_data[:waypoint_number] = 1
    plan.add_waypoint(waypoint_data)
    waypoint_data = WAYPOINT_INFO[index+3]
    waypoint_data[:waypoint_number] = 2
    plan.add_waypoint(waypoint_data)
  end
end