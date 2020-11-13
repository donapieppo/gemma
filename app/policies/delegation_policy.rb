class DelegationPolicy < ApplicationPolicy
  def index?
    current_organization_manager?
  end

  def create?
    record_organization_manager?
  end

  def destroy?
    record_organization_manager?
  end
end
