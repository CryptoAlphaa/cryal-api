# Cryal API

This API stores and retrieve an entry of a person current location and destination location.

## Routes
**The API will be running on `http://localhost:9292/`.** 

All routes are returning as a JSON object. Here are the routes:

1. `GET /`: Get the root of API to check whether the API is Alive or not
2. `GET /api/v1/rooms`: Get all existed rooms
3. `GET /api/v1/rooms/[room_id]`: Get a specific rooms by room_id
4. `GET /api/v1/userrooms`: Get list of connection between user and room
5. `GET /api/v1/accounts`: Get all user
6. `GET /api/v1/accounts/[account_id]`: Get a specific user by account_id
7. `GET /api/v1/accounts/[account_id]/locations`: Get a location of a specific user by account_id
8. `GET /api/v1/accounts/[account_id]/plans/[plan_id]/waypoints`: Get all waypoint of a specific plan from a specific room of a user
9. `GET /api/v1/accounts/[account_id]/plans/fetch/?room_name=#{sendthis['room_name']}`: Get all plan of a specific user by account_id
10. `GET /api/v1/accounts/[account_id]/rooms`: Get all rooms of a specific user by account_id
11. `POST /api/v1/accounts`: Post a new user
12. `POST /api/v1/accounts/[account_id]/createroom`: Post a request to create a new room by a user
13. `POST /api/v1/accounts/[account_id]/joinroom`: Post a request to join a specific room
14. `POST /api/v1/accounts/[account_id]/locations`: Post a request to create a new location by a user
15. `POST /api/v1/accounts/[account_id]/plans`: Post a request to create new plan by a user
16. `POST /api/v1/accounts/[account_id]/plans/[plan_id]/waypoints`: Post a request to create a new waypoint within plan by a user
17. `POST /api/v1/accounts/[account_id]/plans/create_plan`: Post a request to create new plan by a user


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