# frozen_string_literal: true

# Policy to determine if account can view a location data
class LocationPolicy
  def initialize(account, location, auth_scope)
    @account = account
    @location = location
    @auth_scope = auth_scope
  end

  def can_view?
    account_owns_location?
  end

  def summary
    {
      can_view: can_view?
    }
  end

  private

  def account_owns_location?
    @location.select do |loc|
      loc.account == @account
    end
  end

  def can_read?
    @auth_scope ? @auth_scope.can_read?('locations') : false
  end
end
