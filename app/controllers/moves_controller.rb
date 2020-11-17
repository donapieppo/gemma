class MovesController < ApplicationController
  # se chiediamo un certo deposito vediamo tutte le operazioni con i moves di quel deposito
  def index
    authorize Move

    # FIXME TODO REFACTOR
    # per ora cerchiamo tutto e scorriamo saltando quello che non ci interessa
    @display_year = (params[:y] || Date.today.year).to_i
    if params[:thing_id]
      @thing = current_organization.things.find(params[:thing_id]) 
    else 
      @deposit = current_organization.deposits.includes(:location).find(params[:deposit_id])
      @thing = @deposit.thing
    end

    @operations = @thing.operations.ordered.includes(:user, :recipient, ddt: :supplier)
    if @deposit
      @operations = @operations.ordered.includes(:user, :recipient, :moves).where('moves.deposit_id = ?', @deposit.id).references(:moves) 
    end
                                                 
    @deposits = @thing.deposits
  end
end
