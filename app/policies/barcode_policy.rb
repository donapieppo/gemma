class BarcodePolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    record_organization_manager?
  end

  # FIXME
  def generate?
    current_organization_manager?
  end

  def destroy?
    record_organization_manager?
  end

  def zxing_search?
    true
  end
end

