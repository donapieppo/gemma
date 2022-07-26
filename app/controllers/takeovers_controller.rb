class TakeoversController < ApplicationController
  before_action :set_thing, only: [:new, :create]
  before_action :set_takeover_and_thing_and_check_permission, only: [:edit, :update, :destroy]

  def new
    @takeover = @thing.takeovers.new(date: Date.today, organization_id: current_organization.id)
    @numbers  = {}
    authorize @takeover
  end

  def create
    params[:takeover][:numbers] = @numbers = params[:numbers].permit!

    recipient_upn = params[:takeover].delete(:recipient_upn)
    @takeover = @thing.takeovers.new(takeover_params)

    @takeover.organization_id = current_organization.id
    @takeover.user_id = current_user.id
    if recipient_upn =~ /(\w+\.\w+@unibo.it)/
      @takeover.recipient_upn = $1
    end

    authorize @takeover

    # il create non dede raisare perchè sempre history_coherent
    if @takeover.save
      redirect_to group_things_path(@takeover.thing.group_id, from_thing: @takeover.thing.id), notice: 'Presa consegna registrata correttamente.'
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def edit
    @numbers = @takeover.numbers_hash
    render action: :new
  end

  def update
    params[:takeover][:numbers] = params[:numbers]

    begin 
      res = @takeover.aggiorna(takeover_params)
    rescue Gemma::NegativeDeposit => e
      @takeover.errors.add(:base, e.to_s)
      res = false
    end

    if res
      redirect_to thing_moves_path(@takeover.thing_id), notice: 'Aggiornamento avvenuto correttamente'
    else
      @numbers = @takeover.numbers_hash
      render action: :edit, status: :unprocessable_entity
    end
  end

  def destroy
    begin 
      res = @takeover.destroy
    rescue Gemma::NegativeDeposit => e
      @takeover.errors.add(:base, e.to_s)
      res = false
    end

    if res
      flash[:notice] = "L'operazione di presa consegna è stata eliminata."
    else
      flash[:error] = 'Non è stato possibile eliminare la presa consegna. Controllare che la sua cancellazione non precluda scarichi successivi.'
    end

    redirect_to thing_moves_path(@takeover.thing_id)
  end

  private

  def takeover_params
    params[:takeover].permit(:date, :note, numbers: params[:takeover][:numbers].try(:keys))
  end

  def set_thing
    @thing = current_organization.things.includes(:deposits).find(params[:thing_id])
  end

  def set_takeover_and_thing_and_check_permission
    @takeover = current_organization.takeovers.includes([:thing, :user]).find(params[:id])
    @thing = @takeover.thing
    authorize @takeover
  end
end



