# frozen_string_literal: true

module Cryal
  class GetAccountQuery
    class ForbiddenError < StandardError
      def message
        'You are not allowed access this account'
      end
    end

    def self.call(requestor_id:, account_id:)
      account = Account.first(account_id: account_id)
      policy = AccountPolicy.new(requestor_id, account_id)
      policy.can_view? ? account.to_json : raise(ForbiddenError)
    end
  end
end
