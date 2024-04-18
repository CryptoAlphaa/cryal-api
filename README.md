# Cryal API

This API stores and retrieve an entry of a person current location and destination location.


## Installation
Install this API by cloning the repository and also install the required gem from `Gemfile.lock`. Here are the step:

```bash
$ git clone
$ cd cryal-api
$ bundle install
```
## Test

To run the test, run the following command:

```bash
$ ruby spec/api_spec.rb
```

## Execution

To run the API, run the following command:

```bash
$ puma
```

> The API will be running on `http://localhost:9292/`.

1. To send a GET request, you can use the following command:

```bash
$ curl -X GET http://localhost:9292/api/routes/
```

2. To send a POST request, you can use the following command:

```bash
$ curl -X POST http://localhost:9292/api/routes/ -d '[{"origin": {"city": "Los Angeles", "region": "California", "country": "United States", "country_code": "US", "continent": "North America", "longitude": -118.2437, "latitude": 34.0522}, "destination": {"city": "New York", "region": "New York", "country": "United States", "country_code": "US", "continent": "North America", "longitude": -74.0059, "latitude": 40.7128}, "method": "Airplane"}]'
```


## Routes

All routes are returning as a JSON object. Here are the routes:

1. **GET** `/`- This route returns a welcome message "Welcome to Cryal API".

2. **GET** `/api/routes/[id]` - This route returns a single entry of a person current location and destination location.

```json
[
  {
    "id": 1,
    "timestamp": 1708371400,
    "origin": {
      "city": "Los Angeles",
      "region": "California",
      "country": "United States",
      "country_code": "US",
      "continent": "North America",
      "longitude": -118.2437,
      "latitude": 34.0522
    },
    "destination": {
      "city": "New York",
      "region": "New York",
      "country": "United States",
      "country_code": "US",
      "continent": "North America",
      "longitude": -74.0059,
      "latitude": 40.7128
    },
    "method": "Airplane"
  }
]

```

3. **GET** `api/routes/` - This route will return all entries id that exist in the database.

```json
[
  {
    "routes_ids": [1, 2, 3, 4, 5]
  }
]
```

4. **POST** `/api/routes/` - This route stores an entry of a person current location and destination location. The request body should be in the following format:

```json
[
  {
    "id": (optional),
    "timestamp": (optional),
    "origin": {
      "city": "Los Angeles",
      "region": "California",
      "country": "United States",
      "country_code": "US",
      "continent": "North America",
      "longitude": -118.2437,
      "latitude": 34.0522
    },
    "destination": {
      "city": "New York",
      "region": "New York",
      "country": "United States",
      "country_code": "US",
      "continent": "North America",
      "longitude": -74.0059,
      "latitude": 40.7128
    },
    "method": "Airplane"
  }
]
```
