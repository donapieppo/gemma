class TakeoverPolicy < ApplicationPolicy
  def index?
    false
  end

  def create?
    @user && 
    OrganizationPolicy.new(@user, @record.organization).give? && 
    @record.organization_id == @record.thing.organization_id
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end

