class LocationsController < ApplicationController
  before_action :get_location_and_check_permission, only: [:edit, :update, :destroy]

  def index
    authorize Location
    @locations = current_organization.locations.order(:name)
  end

  def new
    @location = current_organization.locations.new
    authorize @location
  end

  def create
    @location = current_organization.locations.new(location_params)
    authorize @location
    if @location.save 
      redirect_to current_organization_edit_path, notice: "L'ubicazione è stata creata."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @location.update(location_params) 
      redirect_to locations_path, notice: "L'ubicazione è stata modificata."
    else
      render :edit
    end
  end

  def destroy
    if @location.destroy
      flash[:notice] = "L'ubicazione è stata cancellata"
    else
      # FIXME
      flash[:error] = @location.errors[:base].first
    end
    redirect_to current_organization_edit_path
  end

  private

  def get_location_and_check_permission
    @location = current_organization.locations.find(params[:id])
    authorize @location
  end

  # can not choose organization_id
  def location_params
    params.require(:location).permit(:name)
  end

end


