class LoginsController < ApplicationController
  skip_before_action :after_current_user_and_organization

  def no_access
    authorize :login
  end
end
