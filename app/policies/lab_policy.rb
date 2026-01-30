class LabPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    current_organization_manager?
  end

  def new?
    current_organization_manager?
  end

  def create?
    current_organization_manager?
  end

  def update?
    current_organization_manager?
  end

  def destroy?
    current_organization_manager?
  end
end
