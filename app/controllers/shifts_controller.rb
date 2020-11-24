class ShiftsController < ApplicationController
  before_action :set_shift_and_check_permission, only: [:edit, :update, :destroy]

  def new
    @thing    = current_organization.things.find(params[:thing_id]) 
    @deposits = @thing.deposits
    @shift    = @thing.shifts.new(date: Date.today, organization_id: current_organization)
    authorize @shift
  end

  # FIXME 
  # se manca params[:shift][:from] deve esserci thing_id per tornare alla pagina move_form
  # "shift"=>{"number"=>"2", "from"=>"308", "to"=>"319"}
  def create
    @thing = current_organization.things.find(params[:thing_id])
    @shift = Shift.new(user_id:         current_user.id,
                       date:            params[:shift][:date],
                       thing_id:        @thing.id,
                       number:          params[:shift][:number].to_i,
                       from:            params[:shift][:from],
                       to:              params[:shift][:to],
                       organization_id: current_organization.id)
    authorize @shift

    begin
      res = @shift.save
    rescue => e
      @shift.errors.add(:base, e.to_s)
      res = false
    end

    if res
      redirect_to thing_moves_path(@thing.id), notice: "Sono stati spostati #{@shift.number} oggetti."
    else
      @deposits = @thing.deposits
      render action: :new
    end
  end

  def edit
  end

  def update
    begin
      res = @shift.update(date: params[:shift][:date])
    rescue => e
      @shift.errors.add(:date, e.to_s)
      res = false
    end

    if res
      redirect_to thing_moves_path(@shift.thing_id), notice: 'La data è stata aggiornata.'
    else
      render action: :edit
    end
  end

  def destroy
    begin
      res = @shift.destroy
    rescue Gemma::NegativeDeposit => e
      flash[:alert] = e.to_s
      res = false
    end

    if res
      flash[:notice] = 'Spostamento correttamente eliminato'
    else
      flash[:alert] ||= "Non è stato possibile eliminare l'operazione. #{@shift.errors.on_base}"
    end

    redirect_to thing_moves_path(@shift.thing_id)
  end

  private

  def set_shift_and_check_permission
    @shift = current_organization.shifts.find(params[:id])
    authorize @shift
  end
end
