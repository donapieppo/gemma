class MovesController < ApplicationController
  # se chiediamo un certo deposito vediamo tutte le operazioni con i moves di quel deposito
  def index
    authorize Move

    if params[:thing_id]
      @thing = current_organization.things.find(params[:thing_id]) 
    else 
      @deposit = current_organization.deposits.includes(:location).find(params[:deposit_id])
      @thing = @deposit.thing
    end

    @operations = @thing.operations.ordered.includes(:user, :recipient, ddt: :supplier)
    if @deposit
      @operations = @operations.ordered.includes(:user, :recipient, :moves)
                               .where('moves.deposit_id = ?', @deposit.id).references(:moves) 
    end

    if @operations.empty?
      redirect_to thing_path(@thing), alert: 'Non sono ancora stati registrati movimenti per il materiale selezionato.'
    else
      @deposits = @thing.deposits

      @first_year = @operations.first.date.year
      @last_year = @operations.last.date.year
      @display_year = (params[:y] || @last_year).to_i
      if @display_year < @first_year || @display_year > @last_year
        @display_year = @last_year
      end
    end
  end
end
