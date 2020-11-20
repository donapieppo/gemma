class DepositsController < ApplicationController
  before_action :set_thing, only: [:new, :create]

  def new
    @deposit = @thing.deposits.new(organization_id: current_organization.id)
    authorize @deposit

    @actual_locations = @thing.locations
    @other_locations  = current_organization.locations - @actual_locations
  end

  # "thing"=>{"location_ids"=>["222", "223", ""]}, "commit"=>"Aggiungi", "thing_id"=>"12058"}
  def create
    if params[:thing] and params[:thing][:location_ids]
      params[:thing][:location_ids].each do |loc_id|
        loc_id.blank? and next
        @deposit = current_organization.deposits.new(thing_id:    @thing.id,
                                                     location_id: loc_id,
                                                     actual:      0)
        authorize @deposit
        if ! @deposit.save
          redirect_to new_thing_deposit_path(@thing), alert: "Errore nell'aggiunta dell'articolo."
          return                      
        end
      end
      redirect_to edit_thing_path(@thing), notice: "Le nuove ubicazioni sono state stata aggiunte."
    else
      skip_authorization
      redirect_to new_thing_deposit_path(@thing), alert: "Non è stata selezionata nessuna ubicazione."
    end
  end

  def destroy
    deposit = current_organization.deposits.find(params[:id]) 
    authorize deposit

    if deposit.destroy
      flash[:notice] = "Il deposito è stato cancellato come richiesto."
    else
      flash[:error] = "Ci sono carichi e scarichi legati al deposito. Non è possibile eseguire l'operazione."
    end

    redirect_to edit_thing_path(deposit.thing_id)
  end

  private 

  def set_thing
    @thing = current_organization.things.find(params[:thing_id]) 
  end
end

