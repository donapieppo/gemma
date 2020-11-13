class StockPolicy < ApplicationPolicy
  def index?
    false
  end

  def create?
    @user && 
    OrganizationPolicy.new(@user, @record.organization).manage? && 
    @record.organization_id == @record.thing.organization_id
  end

  def update?
    create?
  end

  def signing?
    create?
  end
end

