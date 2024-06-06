# frozen_string_literal: true

# Policy to determine if account can view a location data
class LocationPolicy
    def initialize(account, location)
      @account = account
      @location = location
    end

    def can_view?
        account_owns_location?
    end
    
    def summary
    {
        can_view: can_view?,
    }
    end

    private

    def account_owns_location?
      @location.select do |loc|
        loc.account == @account
      end
    end
end