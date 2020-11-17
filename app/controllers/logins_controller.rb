class LoginsController < ApplicationController
  skip_before_action :set_booking_organization

  def no_access
    authorize :login
  end
end

