class MovesController < ApplicationController
  def index
    authorize :move

    if params[:thing_id]
      @thing = current_organization.things.find(params[:thing_id])
    else
      @deposit = current_organization.deposits.includes(:location).find(params[:deposit_id])
      @thing = @deposit.thing
    end

    @moves = Move
      .joins(:operation)
      .where(operation: {thing_id: @thing.id})
      .includes(deposit: :location, operation: [:picking_point, :cost_center, :user, :recipient, ddt: :supplier])
      .order("operation.date ASC, operation.number DESC")

    @moves = if @deposit
      @moves.where(deposit_id: @deposit.id)
    else
      @moves.group(:operation_id)
    end

    @moves.load

    if @moves.any?
      @deposits = @thing.deposits

      @first_year = @moves.first.operation.date.year
      @last_year = @moves.last.operation.date.year
      @display_year = (params[:y] || @last_year).to_i
      if @display_year < @first_year || @display_year > @last_year
        @display_year = @last_year
      end
    else
      redirect_to thing_path(@thing), alert: "Non sono ancora stati registrati movimenti per il materiale selezionato."
    end
  end
end
