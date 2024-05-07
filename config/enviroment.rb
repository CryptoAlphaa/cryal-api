# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'sequel'
require './app/lib/secure_db'

module Cryal
  # Configuration for the API
  class Api < Roda
    plugin :environments
    configure do
      # load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment: environment, # rubocop:disable Style/HashSyntax
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      # Make the environment variables accessible to other classes
      def self.config = Figaro.env

      # Connect and make the database accessible to other classes
      db_url = ENV.delete('DATABASE_URL')
      DB = Sequel.connect("#{db_url}?encoding=utf8")
      def self.DB = DB # rubocop:disable Naming/MethodName

      configure :development, :production do
        plugin :common_logger, $stdout
      end

      LOGGER = Logger.new($stderr)
      def self.logger = LOGGER

      # Retrieve and Delete secret DB Key
      SecureDB.setup(ENV.delete('DB_KEY'))

      configure :development, :test do
        require 'pry'
        logger.level = Logger::ERROR
      end
    end
  end
end
