# Cryal API

This API stores and retrieve an entry of a person current location and destination location.

## Routes
** The API will be running on `http://localhost:9292/`.** 

All routes are returning as a JSON object. Here are the routes:

1. GET /

Get the root of API to check whether the API is Alive or not

2. GET api/v1/location

Get all location existed in the databse

3. GET api/v1/location/[id]

Get description of a specific location via id

4. GET api/v1/rooms

Get all rooms existed in the database

5. GET api/v1/rooms/[id]

Get description of a specific room via id

6. GET api/v1/targets

Get all target destination existed in the database

7. GET api/v1/targets/[id]

Get description of a specific targets destination via id

8. GET api/v1/user_room/[id]

Get description of a specific user_room via id

9. GET api/v1/userroom

To get a list of existing user rooms

10. GET api/v1/users

To get a list of information of all users

11. GET api/v1/users/[id]

To get information of a certain user

12. GET api/v1/users/[id]/location

To get all the location of a user

13. POST api/v1/targets

Allows to create destination location

14. POST api/v1/users

Allows to create new users

15. POST api/v1/users/[id]/createroom

Allows users to create a room

16. POST api/v1/users/[id]/joinroom

Allows users to join a room

17. POST api/v1/users/[id]/location

Allows user to create locations


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

Run the test specification script in `Rakefile`:

```shell
rake spec
```