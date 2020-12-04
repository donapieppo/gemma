class HelpsController < ApplicationController
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

