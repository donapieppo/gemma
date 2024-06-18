class LoadsController < ApplicationController
  include PriceMethods

  before_action :set_thing, only: [:new, :create]
  before_action :set_load_and_thing_and_check_permission, only: [:edit, :update, :destroy]

  def new
    if @thing.deposits.empty?
      skip_authorization
      redirect_to edit_thing_path(@thing), alert: "Non è stata ancora definita una ubicazione per il materiale."
    else
      @load = @thing.loads.new(date: Date.today, organization_id: current_organization.id)
      @numbers = {}
      authorize @load
    end
  end

  # load: {"thing_id"=>"3998", "numbers"=>{"4003"=>"12", "4005"=>"21"}, "price_int"=>"2", "price_dec"=>"0"}
  def create
    params[:load][:numbers] = @numbers = params[:numbers].permit!
    params[:load] = fix_prices(params[:load], params["price_add_iva"])

    @load = @thing.loads.new(load_params)

    @load.organization_id = current_organization.id
    @load.user_id = current_user.id

    authorize @load

    # il create non vede raisare perche' sempre history_coherent
    if @load.save
      flash[:notice] = "Carico di #{@load.number} <strong>#{view_context.link_to(@thing, thing_moves_path(@thing)).html_safe}</strong> registrato correttamente e associato al ddt/fattura con RECORD N. #{@load.ddt.number.to_i}.".html_safe
      redirect_to group_things_path(@thing.group_id, from_thing: @thing.id)
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def edit
    @numbers = @load.numbers_hash
    render action: :new
  end

  def update
    params[:load] = fix_prices(params[:load], params["price_add_iva"])
    params[:load][:numbers] = @numbers = params[:numbers]

    begin
      res = @load.aggiorna(load_params)
    rescue Gemma::NegativeDeposit => e
      @load.errors.add(:base, e.to_s)
      res = false
    end

    if res
      redirect_to thing_moves_path(@load.thing_id), notice: "Aggiornamento avvenuto correttamente."
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      res = @load.destroy
    rescue Gemma::NegativeDeposit => e
      flash[:error] = e.to_s
      res = false
    end

    if res
      flash[:notice] = "Carico eliminato."
      if @load.ddt.operations.count < 1
        flash[:notice] += "Avviso: Non ci sono più carichi associati al ddt/fattura Record N. #{@load.ddt.number}."
      end
    else
      flash[:error] ||= "Non è stato possibile eliminare il carico: #{@load.errors.on_base}."
    end

    redirect_to thing_moves_path(@load.thing_id)
  end

  private

  # remember update e' in realta' un aggiorna nel load module (operation)
  def load_params
    params[:load].permit(
      :number, :recipient, :date, :ddt_id, :note, :ycia, :ncia, :price, :price_int, :price_dec,
      numbers: params[:load][:numbers].try(:keys)
    )
  end

  def set_thing
    @thing = current_organization.things.includes(:deposits).find(params[:thing_id])
  end

  def set_load_and_thing_and_check_permission
    @load = current_organization.loads.includes(:thing).find(params[:id])
    @thing = @load.thing
    authorize @load
  end
end
