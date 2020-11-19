class ShiftPolicy < ApplicationPolicy
  def index?
    false
  end

  def create?
    current_organization_manager?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end

