class GroupPolicy < ApplicationPolicy
  def index?
    @user && OrganizationPolicy.new(@user, @user.current_organization).read?
  end

  def create?
    record_organization_manager?
  end

  def update?
    record_organization_manager?
  end

  def destroy?
    record_organization_manager?
  end
end

