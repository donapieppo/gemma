class HelpsController < ApplicationController
  def index
    authorize :help
  end

  def contacts
    authorize :help
  end
end

