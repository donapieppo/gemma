class ApplicationPolicy < DmUniboCommon::ApplicationPolicy
  def current_organization_reader?
    @user && OrganizationPolicy.new(@user, @user.current_organization).read?
  end
end
