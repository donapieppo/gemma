class InfoPolicy < ApplicationPolicy
  def index?
    @user.is_cesia?
  end

  def organization?
    index?
  end
end

