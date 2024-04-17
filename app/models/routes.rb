# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Cryal
  STORE_DIR = 'app/db/store'

    class Routes
        def initialize(route)
            @id          = route['id'] || new_id
            @origin    = route['origin']
            @destination = route['destination']
            @method     = route['method']
            @timestamp = route['timestamp'] || Time.now.to_f
        end

        attr_reader :id, :origin, :destination, :method, :timestamp

        def to_json(*_args)
            {
                id: id,
                origin: origin,
                destination: destination,
                method: method,
                timestamp: timestamp
            }.to_json(*_args)
        end

    def self.setup
      Dir.mkdir(Cryal::STORE_DIR) unless Dir.exist? Cryal::STORE_DIR
    end

    def save
      File.write("#{Cryal::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one document
    def self.find(find_id)
      file = File.read("#{Cryal::STORE_DIR}/#{find_id}.txt")
      Routes.new JSON.parse(file)
    end

        # Query method to retrieve index of all documents
        def self.all
            Dir.glob("#{Cryal::STORE_DIR}/*.txt").map do |f|
                File.basename(f, '.txt')
            end
        end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
