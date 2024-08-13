class HomeController < ApplicationController
  skip_before_action :force_sso_user, :after_current_user_and_organization, raise: false

  def index
    skip_authorization
    if current_user&.current_organization
      redirect_to groups_path(__org__: current_user.current_organization.code) and return
    elsif current_user
      @available_organizations = current_user.my_organizations(ordering: :code)
    end
  end
end
