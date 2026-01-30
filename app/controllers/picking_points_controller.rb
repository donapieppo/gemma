class PickingPointsController < ApplicationController
  before_action :set_picking_point_and_check_permission, only: [:show, :edit, :update, :destroy]

  def index
    authorize :picking_point
    @picking_points = current_organization.picking_points.order(:name)
  end

  def show
    @operations = @picking_point.operations
  end

  def new
    @picking_point = current_organization.picking_points.new
    authorize @picking_point
  end

  def create
    @picking_point = current_organization.picking_points.new(picking_point_params)
    authorize @picking_point
    if @picking_point.save
      redirect_to picking_points_path, notice: "Punto di ritiro creato correttamente."
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @picking_point.update(picking_point_params)
      redirect_to picking_points_path, notice: "Il punto di ritiro è stato modificato."
    else
      render action: :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @picking_point.destroy
      flash[:notice] = "Il punto di ritiro è stato cancellato come richiesto."
    else
      flash[:error] = "Ci sono scarichi/prenotazioni legati al punto di ritiro. Non è possibile eseguire l'operazione."
    end

    redirect_to [:edit, @picking_point]
  end

  private

  def picking_point_params
    params[:picking_point].permit(:name, :description)
  end

  def set_picking_point_and_check_permission
    @picking_point = current_organization.picking_points.find(params[:id])
    authorize @picking_point
  end
end
