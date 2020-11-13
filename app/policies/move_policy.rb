class MovePolicy < ApplicationPolicy
  def index?
    @user && OrganizationPolicy.new(@user, @user.current_organization).read?
  end
end

