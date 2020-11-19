class ImagePolicy < ApplicationPolicy
  def index?
    @user.is_cesia?
  end

  # images does't belong to organization. Thing does
  def create?
    @user && OrganizationPolicy.new(@user, @record.thing.organization).manage?
  end

  def destroy?
    @user && OrganizationPolicy.new(@user, @record.thing.organization).manage?
  end
end

