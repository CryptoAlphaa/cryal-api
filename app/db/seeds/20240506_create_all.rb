Sequel.seed(:development) do
  def run
    create_users
    # add_locations
    # create_rooms
    # create_plans
    # create_waypoints
    # create_user_rooms
  end
end

# load all yaml seeds
require 'yaml'
DIR = File.dirname(__FILE__)
USER_INFO = YAML.load_file("#{DIR}/users_seeds_seeder.yml")
# LOCATION_INFO = YAML.load_file("#{DIR}/locations_seeds.yml")
# ROOM_INFO = YAML.load_file("#{DIR}/rooms_seeds.yml")
# PLAN_INFO = YAML.load_file("#{DIR}/plans_seeds.yml")
# WAYPOINT_INFO = YAML.load_file("#{DIR}/waypoints_seeds.yml")
# USER_ROOM_INFO = YAML.load_file("#{DIR}/user_rooms_seeds.yml")

def create_users
  USER_INFO.each do |data|
    Cryal::User.create(data)
  end
end

# def add_locations
#   user = Cryal::User.first(username: )
# end

# def create_rooms

# end

# def create_plans


# end

# def create_waypoints


# end


# def create_user_rooms

# end
