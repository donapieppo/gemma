class ArchPolicy < ApplicationPolicy
  def index?
    current_organization_manager?
  end

  def list?
    current_organization_manager?
  end
end
