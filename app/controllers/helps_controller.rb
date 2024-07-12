class HelpsController < ApplicationController
  skip_before_action :after_current_user_and_organization

  def index
    authorize :help
  end

  def contacts
    authorize :help
  end

  def old_url
    authorize :help
  end
end
