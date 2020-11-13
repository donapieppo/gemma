class DsauserPolicy < ApplicationPolicy
  def popup_find?
    true
  end

  def find?
    OrganizationPolicy.new(@user, @user.current_organization).give?
  end
end
