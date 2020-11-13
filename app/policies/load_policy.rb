class LoadPolicy < ApplicationPolicy
  def create?
    record_organization_manager? 
  end

  def update?
    record_organization_manager?
  end
end

