class ThingPolicy < ApplicationPolicy
  def index?
    @user && OrganizationPolicy.new(@user, @user.current_organization).read?
  end

  def find?
    index?
  end

  def show?
    index?
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

  def inactive?
    current_organization_manager?
  end

  def recalculate_prices?
    record_organization_manager?
  end

  def generate_barcode?
    update?
  end
end

