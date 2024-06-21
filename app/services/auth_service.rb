# frozen_string_literal: true

module Cryal
  # Authenticate Module
  module Authenticate
    @err_message = 'User or Password not found!'
    extend Cryal
    def self.call(routing, json)
      account = Cryal::Account.first(username: json[:username]) # user existed
      # raise error if user not found
      not_found(routing, @err_message, 403) if account.nil?
      # password
      begin
        jsonify = JSON.parse(account.password_hash)
      rescue JSON::ParserError
        raise @err_message
      end
      salt = Base64.strict_decode64(jsonify['salt'])
      checksum = jsonify['hash']
      extend KeyStretch
      check = Base64.strict_encode64(password_hash(salt, json[:password]))
      not_found(routing, @err_message, 403) unless check == checksum
      account_and_token(account)
    end

    def self.account_and_token(account)
      {
        type: 'authenticated_account',
        attributes: {
          account:,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end

  module AuthViaSSO
    class AuthorizeSso
      def call(access_token)
        github_account = get_github_account(access_token)
        sso_account = find_or_create_sso_account(github_account)

        account_and_token(sso_account)
      end

      def get_github_account(access_token)
        github_response = HTTP.headers(
          user_agent: 'Cryal', authorization: "token #{access_token}",
          accept: 'application/json'
        ).get(ENV['GITHUB_ACCOUNT_URL'])

        raise unless github_response.status == 200

        # puts "gh response: #{github_response.inspect}"
        account = GithubAccount.new(JSON.parse(github_response))
        { username: account.username, email: account.email }
      end

      def find_or_create_sso_account(account_data)
        Account.username_exist?(account_data[:username]) ||
          # Cryal::Account.new(account_data)
          Account.create_github_account(account_data)
      end

      def account_and_token(account)
        {
          type: 'sso_account',
          attributes: {
            account:,
            auth_token: AuthToken.create(account)
          }
        }
      end
    end
  end
end
