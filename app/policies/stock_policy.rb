class StockPolicy < ApplicationPolicy
  def index?
    false
  end

  def create?
    record_organization_manager?
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

