# Cryal API

This API stores and retrieve an entry of a person current location and destination location.

## Routes
**The API will be running on `http://localhost:9292/`.** 

All routes are returning as a JSON object that contain all of data that can be accesed by the auth_account. Here are the routes:

1. `DELETE /api/v1/rooms/delete?room_id=room_id` : Delete a specific room by room_id
2. `DELETE /api/v1/rooms/exit?room_id=room_id` : Exit a specific room by room_id
3. `DELETE /api/v1/rooms/room_id/plans/plan_id/waypoints?waypoint_id=waypoint_id` : Delete a waypoint by waypoint_id
4. `DELETE /api/v1/rooms/room_id/plans?plan_name=plan_name` : Delete a plan by plan_name
5. `GET /` : Get all existed rooms
6. `GET /api/v1/accounts?username=username` : Get an account by username
7. `GET /api/v1/global/rooms` : Get all rooms
8. `GET /api/v1/global/rooms/[room_id]` : Get a specific room by room_id
9. `GET /api/v1/global/userrooms` : Get all userrooms
10. `GET /api/v1/locations` : Get a user location
11. `GET /api/v1/rooms/room_id/plans/plan_id/waypoints?waypoint_number=waypoint_number` : Get a specific waypoint by waypoint_number
12. `GET /api/v1/rooms/room_id/plans?plan_name=plan_name` : Get a plan by plan_name
13. `GET /api/v1/rooms?room_id=room_id` : Get a room by room_id
14. `POST /api/v1/accounts` : Create a new account
15. `POST /api/v1/auth/authentication` : Authenticate an account
16. `POST /api/v1/auth/register` : Send a verification email
17. `POST /api/v1/locations` : Create a location
18. `POST /api/v1/rooms/createroom` : Create a room
19. `POST /api/v1/rooms/joinroom` : Join a room
20. `POST /api/v1/rooms/room_id/plans` : Create a plan
21. `POST /api/v1/rooms/room_id/plans/plan_id/waypoints` : Create a waypoint inside a plan

## Installation
Install this API by cloning the repository and also install the required gem from `Gemfile.lock`. Here are the step:

```bash
$ git clone
$ cd cryal-api
$ bundle install
```
Setup development database once:

```shell
rake db:migrate
```

## Execute

Run this API using:

```shell
puma
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```
> If the migration fails, check whether you already have `store` folder inside `db` directory

Run the test specification script in `Rakefile`:

```shell
rake spec
```
