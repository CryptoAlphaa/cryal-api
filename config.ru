# frozen_string_literal: true

# frozen_string_literal: true

# require './app/controllers/app'
require './require_app'
require_app
run Cryal::Api.freeze.app
