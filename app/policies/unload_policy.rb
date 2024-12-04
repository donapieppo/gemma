class UnloadPolicy < ApplicationPolicy
  def index?
    current_organization_reader?
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

  def batch_unloads?
    current_organization_manager?
    # @user &&
    # OrganizationPolicy.new(@user, @record.organization).unload? &&
    # @record.organization_id == @record.thing.organization_id
  end
end
