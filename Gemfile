# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'http'
gem 'json'
gem 'puma', '~>6.1'
gem 'roda', '~>3.1'

# Security
gem 'base64'
gem 'rbnacl', '~>7.1'

# Testing
gem 'minitest'
gem 'minitest-rg'
gem 'rack-test'

# Debugging
gem 'pry'
gem 'rerun'

# Configuration
gem 'figaro'
gem 'pkg-config'
gem 'rake'

# Quality
gem 'rubocop'

# Database
gem 'hirb', '~>0.7'
gem 'sequel', '~>5.67'

group :production do
  gem 'pg'
end

group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end
