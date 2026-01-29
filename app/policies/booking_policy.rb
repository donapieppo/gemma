class BookingPolicy < ApplicationPolicy
  # current_user bookings
  def index?
    @user.current_organization.booking
  end

  def create?
    @user &&
      OrganizationPolicy.new(@user, @record.organization).book? &&
      @record.organization_id == @record.thing.organization_id
  end

  def confirm?
    current_organization_manager?
  end

  def confirm_all?
    current_organization_manager?
  end

  # def edit?
  #   record_organization_manager?
  # end
  #
  # def delete_and_new_unload?
  #   record_organization_manager?
  # end

  def destroy?
    owner_or_record_organization_manager?
  end
end
