class ImagePolicy < ApplicationPolicy
  def index?
    @user.is_cesia?
  end

  def create?
    @user && OrganizationPolicy.new(@user, @record.thing.organization).manage?
  end

  def destroy?
    @user && OrganizationPolicy.new(@user, @record.thing.organization).manage?
  end
end

