class UnloadPolicy < ApplicationPolicy
  def index?
    false
  end

  def create?
    @user && 
    OrganizationPolicy.new(@user, @record.organization).unload? && 
    @record.organization_id == @record.thing.organization_id
  end

  def update?
    create?
  end

  def signing?
    create?
  end

  def destroy?
    create?
  end
end

