class StocksController < ApplicationController
  include PriceMethods

  before_action :set_thing, only: [:new, :create]
  before_action :set_stock_and_thing_and_check_permission, only: [:edit, :update, :destroy]

  def new
    @thing.has_operation? and raise "Non si può avere giacenza inizale. Ci sono altri carichi"
    @stock = @thing.stocks.new(date: Date.today, organization_id: current_organization.id)
    authorize @stock
    @numbers = {}
  end

  def create
    @thing.has_operation? and raise "Non si può inserire una giacenza inizale in quanto sono presenti altri carichi"

    params[:stock][:numbers] = @numbers = params[:numbers]
    fix_prices(params[:stock], params["price_add_iva"])

    @stock = @thing.stocks.new(stock_params)

    # @stock.numbers         = @numbers
    @stock.organization_id = current_organization.id
    @stock.user_id = current_user.id

    authorize @stock

    # il create non vede raisare perche' sempre history_coherent
    if @stock.save
      redirect_to group_things_path(@stock.thing.group_id), notice: "La giacenza iniziale è stata registrata correttamente."
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def edit
    # @numbers = @stock.moves.inject({}) {|numbers, move| numbers[move.deposit_id] = move.number; numbers }
    @numbers = @stock.moves.each_with_object({}) { |move, numbers| numbers[move.deposit_id] = move.number }

    if current_organization.pricing
      @price_int = @stock.price_int
      @price_dec = @stock.price_dec
    end

    render action: :new
  end

  def update
    params[:stock] = fix_prices(params[:stock], params["price_add_iva"])

    params[:stock][:numbers] = params[:numbers].permit!

    begin
      res = @stock.aggiorna(stock_params)
    rescue Gemma::NegativeDeposit => e
      @stock.errors.add(:base, e.to_s)
      res = false
    end

    if res
      redirect_to thing_moves_path(@stock.thing_id), notice: "La giacenza iniziale è stata correttamente aggiornata."
    else
      @numbers = @stock.moves.each_with_object({}) { |move, numbers| numbers[move.deposit_id] = move.number }
      render action: :new, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      res = @stock.destroy
    rescue Gemma::NegativeDeposit => e
      flash[:alert] = e.to_s
      res = false
    end

    if res
      flash[:notice] = "La giacenza iniziale è stata eliminata."
    else
      flash[:alert] ||= "Non è stato possibile eliminare la giacenza iniziale. #{@stock.errors.on_base}."
    end

    redirect_to thing_moves_path(@thing)
  end

  private

  def stock_params
    params[:stock].permit(:number, :date, :ddt_id, :note, :price, :price_int, :price_dec, numbers: params[:stock][:numbers].try(:keys))
  end

  def set_thing
    @thing = current_organization.things.includes(:deposits).find(params[:thing_id])
  end

  def set_stock_and_thing_and_check_permission
    @stock = current_organization.stocks.includes(:thing).find(params[:id])
    @thing = @stock.thing
    authorize @stock
  end
end
