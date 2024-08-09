require "barby/barcode/code_128"
require "barby/outputter/png_outputter"
require "prawn/labels"

class BarcodesController < ApplicationController
  before_action :set_thing, only: [:new, :create]

  def show
    @barcode = current_organization.barcodes.find(params[:id])
    authorize @barcode
    render layout: nil
  end

  def new
    @barcode = @thing.barcodes.new(organization_id: current_organization.id)
    authorize @barcode
  end

  def create
    @barcode = @thing.barcodes.new(barcode_params)
    @barcode.organization_id = current_organization.id
    authorize @barcode

    if @barcode.save
      redirect_to edit_thing_path(@thing), notice: "Il Codice a Barre è stato associato all'articolo #{@thing}"
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def destroy
    barcode = current_organization.barcodes.find(params[:id])
    authorize barcode

    if barcode.destroy
      flash[:notice] = "Il codice a barre è stato cancellato come richiesto."
    else
      flash[:error] = "Non è stato possibile cancellare il codice a barre."
    end

    redirect_to edit_thing_path(barcode.thing_id)
  end

  def zxing_search
    authorize Barcode
    thing = current_organization.things
      .includes(:barcodes)
      .where("barcodes.name = ?", params[:bc].strip).references(:barcodes)
      .first
    if thing
      redirect_to new_thing_unload_path(thing)
    else
      redirect_to root_path, alert: "Codice a barre non presente nel sistema."
    end
  end

  private

  def barcode_params
    params.require(:barcode).permit(:name)
  end

  def set_thing
    @thing = current_organization.things.find(params[:thing_id])
  end
end
