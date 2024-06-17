class HomeController < ApplicationController
  skip_before_action :force_sso_user, :redirect_unsigned_user, :check_role, :after_current_user_and_organization, raise: false

  def index
    skip_authorization
    if current_user&.current_organization
      redirect_to groups_path(__org__: current_user.current_organization.code) and return
    end
  end
end
