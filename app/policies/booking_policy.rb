class BookingPolicy < ApplicationPolicy
  # current_user bookings
  def index?
    @user.current_organization.booking
  end

  def create?
    @user && 
    @record.organization.booking &&
    OrganizationPolicy.new(@user, @record.organization).book? && 
    @record.organization_id == @record.thing.organization_id 
  end

  def confirm?
    current_organization_manager?
  end

  def edit?
    record_organization_manager?
  end
end

