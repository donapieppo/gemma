class DdtPolicy < ApplicationPolicy
  def index?
    current_organization_manager?
  end

  def search_cia?
    index?
  end

  def search?
    index?
  end

  def show?
    record_organization_manager?
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

