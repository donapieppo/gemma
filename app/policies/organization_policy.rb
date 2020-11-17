class OrganizationPolicy < DmUniboCommon::OrganizationPolicy
  configure_authlevels

  def index?
    @user.is_cesia?
  end

  # user in organizations with booking can read
  def read?
    @user && @user.current_organization && (@user.authorization.can_read?(@user.current_organization) || @user.current_organization.booking)
  end

  def book?
    @user && @user.current_organization && @user.current_organization.booking && (! @user.authorization.can_only_book?(@user.current_organization))
  end

  def show?
    @user.is_cesia? || @user.can_read?(@record)
  end

  def edit?
    update?
  end

  def update?
    @user.is_cesia? || @user.can_manage?(@record)
  end

  def choose_organization?
    true
  end

  def booking_accept?
    true
  end

  def start_booking?
    true
  end
end

