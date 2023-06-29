class LabsController < ApplicationController
  before_action :set_lab_and_check_permission, only: [:show, :edit, :update, :delete]

  def index
    authorize :lab
    @labs = current_organization.labs
  end

  def show
    @disposals = @lab.operations
  end

  def new
    @lab = current_organization.labs.new
    authorize @lab
  end

  def create
    @lab = current_organization.labs.new(lab_params)
    authorize @lab
    if @lab.save
      redirect_to labs_path, notice: "Laboratorio creato correttamente."
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @lab.update(lab_params)
      redirect_to labs_path, notice: "Il nome del laboratorio è stato modificato."
    else
      @buildings = current_organization.buildings.to_a
      render action: :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def lab_params
    params[:lab].permit(:name)
  end

  def set_lab_and_check_permission
    @lab = current_organization.labs.find(params[:id])
    authorize @lab
  end
end
