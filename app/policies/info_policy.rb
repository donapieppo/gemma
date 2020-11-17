class InfoPolicy < ApplicationPolicy
  def index?
    @user.is_cesia?
  end
end

