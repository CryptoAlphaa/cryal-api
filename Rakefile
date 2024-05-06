# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task default: :spec

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby spec/integration/api_spec.rb'
end

# desc 'Test all the specs'
# Rake::TestTask.new(:spec) do |t|
#   t.pattern = 'spec/unit/users_spec.rb'
#   t.warning = false
# end

desc 'Test API functionality specs only'
Rake::TestTask.new(:function) do |t|
  t.pattern = 'spec/integration/*.rb'
  t.warning = false
end

desc 'Test API security specs only'
Rake::TestTask.new(:security) do |t|
  t.pattern = 'spec/integration/security/*.rb'
  t.warning = false
end

desc 'Test models specs only'
Rake::TestTask.new(:model) do |t|
  t.pattern = 'spec/unit/*.rb'
  t.warning = false
end

desc 'Test environment specs only'
Rake::TestTask.new(:envspec) do |t|
  t.pattern = 'spec/env_spec.rb'
  t.warning = false
end

desc 'Run both unit and security specs'
task specs: %i[function security model envspec]

desc 'Runs rubocop on tested code'
task style: %i[spec audit] do
  sh 'rubocop .'
end

desc 'Update vulnerabilities lit and audit gems'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Checks for release'
task release?: %i[spec style audit] do
  puts "\nReady for release!"
end

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task console: :print_env do
  sh 'pry -r ./spec/test_load_all'
end

namespace :db do # rubocop:disable Metrics/BlockLength
  task :load do
    require_app(nil) # load nothing by default
    require 'sequel'
    Sequel.extension :migration
    @app = Cryal::Api
  end

  task :load_models do
    require_app('models')
  end

  desc 'Run migrations'
  task migrate: %i[load print_env] do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(@app.DB, 'app/db/migrations')
  end

  desc 'Destroy data in database; maintain tables'
  task delete: :load_models do
    Cryal::Project.dataset.destroy
  end

  desc 'Delete dev or test database file'
  task drop: :load do
    if @app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "app/db/store/#{Cryal::Api.environment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end

  desc 'Delete all data'
  task :reset_seeds => [:load, :load_models] do
    @app.DB[:schema_seeds].delete if @app.DB.tables.include?(:schema_seeds)
    Cryal::User.dataset.destroy # masih belom jalan karna kita msh blm beresin associations buat cascade delete\
    # Cryal::Room.dataset.destroy # blm fix karna figma blm di benerin aku bingung wakawkawkwakwa
    # kalo delete user semua table kedelete karna mereka butuh foreign key
  end

  desc 'Seed the db with data'
  task :seed => [:load, :load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(@app.DB, 'app/db/seeds')
  end

  desc 'Delete data and reseed'
  task :reseed => [:load, :reset_seeds, :seed]
end

namespace :newkey do
  desc 'Create sample cryptographic key for database'
  task :db do
    require_app('lib', config: false)
    puts "DB_KEY: #{SecureDB.generate_key}"
  end
end
