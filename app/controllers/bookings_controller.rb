class BookingsController < ApplicationController
  before_action :set_thing, only: [:new, :create]
  before_action :set_booking_and_check_permission, only: [:destroy, :confirm]

  def index
    authorize Booking

    @user = User.find(params[:user_id]) if params[:user_id]
    @thing = Thing.find(params[:thing_id]) if params[:thing_id]
    @barcode = current_organization.barcodes.includes(:thing).where(name: params[:barcode]).first if params[:barcode]

    @books = current_organization.bookings.includes(:recipient, :user, :thing, :lab, [moves: [deposit: :location]]).order(:date)

    if policy(current_organization).give?
      if @user
        @books = @books.where(user: @user).or(@books.where(recipient: @user))
      elsif @thing
        @books = @books.where(thing: @thing)
      elsif @barcode
        @thing = @barcode.thing
        @books = @barcode ? @books.where(thing_id: @barcode.thing_id) : Booking.none
      end
      @delegations = delegations_hash
      @cache_users = User.bookers_in_cache(current_organization.id)
    else
      @books = @books.where(user_id: current_user.id)
      render :mylist
    end
  end

  def new
    if @thing.total == 0
      skip_authorization
      redirect_to group_things_path(@thing.group_id), alert: "Non sono presenti - #{@thing} - da scaricare."
    else
      @book = @thing.bookings.new(organization_id: current_organization.id)
      authorize @book
      @delegators = current_user.get_delegators(current_organization.id).to_a.push(current_user)
    end
  end

  def create
    # lab only if didattica is on
    params[:booking].delete(:lab_id) unless params[:didattica] == "on"

    @book = @thing.bookings.new(
      organization_id: current_organization.id,
      user_id: current_user.id,
      date: Date.today
    )
    @book.assign_attributes(booking_params)
    authorize @book

    begin
      res = @book.save
    rescue Gemma::NegativeDeposit => e
      @book.errors.add(:base, e.to_s)
      res = false
    end

    if res
      redirect_to bookings_path(highlight: @book), notice: "Prenotazione effettuata correttamente."
    else
      @delegators = current_user.get_delegators(current_organization.id).to_a.push(current_user)
      render action: :new, status: :unprocessable_entity
    end
  end

  # def edit
  # end

  # can confirm or edit
  # if edit we delete the booking and show a precompiled new unload
  # FIXME don't care for deposits, chooses the operator
  # def delete_and_new_unload
  #   @thing = Thing.find(params[:thing_id])
  #
  #   if @book
  #     Rails.logger.info("delete_and_new_unload: delete #{@book.inspect}")
  #     @book.destroy
  #   end
  #
  #   # can't create before @boo destroy or checks app/model/operation fails
  #   @unload = @thing.unloads.new(
  #     recipient_id: params[:recipient_id],
  #     date: params[:date],
  #     lab_id: params[:lab_id],
  #     note: params[:note],
  #     number: params[:number]
  #   )
  #
  #   render "unloads/new"
  # end

  def destroy
    if @book.destroy
      flash[:notice] = "La prenotazione è stata cancellata."
    else
      flash[:error] = "Errore sulla cancellazione."
    end
    redirect_to bookings_path
  end

  def confirm
    if @book.confirm
      flash[:notice] = "La prenotazione è stata confermata."
    else
      flash[:error] = "Errore sulla conferma dello scarico."
    end
    redirect_to bookings_path
  end

  def confirm_all
    authorize :booking
    current_organization.bookings.where(id: params[:booking_ids], user_id: params["user_id"]).each do |booking|
      booking.confirm
    end
    redirect_to bookings_path
  end

  private

  # FIXME
  def booking_params
    cold_dewar = false # default dalse per ora non si modifica

    # ricorda che per avere permit la key deve essere string
    # FIXME (else?)
    if (deposit_id = params[:booking].delete(:deposit_id))
      number = params[:booking].delete(:number).to_i

      if !cold_dewar && @thing.dewars&.any? && Rails.configuration.dewar_liters_and_hot_liters[number]
        Rails.logger.info "Hot Dewar con number=#{number.inspect}"
        number = Rails.configuration.dewar_liters_and_hot_liters[number]
      end
      params[:booking][:numbers] = {deposit_id => number * -1}
    end

    params[:booking].permit(:number, :note, :recipient_id, :lab_id, numbers: params[:booking][:numbers].try(:keys))
  end

  def set_booking_and_check_permission
    @book = current_organization.bookings.find(params[:id])
    # solo amministratore/bidello ha a che fare con ordini altrui
    unless policy(current_organization).give?
      (@book.user_id == current_user.id) or raise Gemma::InsufficientRights, "Errore di autorizzazione in prenotazione upn"
    end
    authorize @book
  end

  def set_thing
    @thing = current_organization.things.includes(:locations).find(params[:thing_id])
  end

  def delegations_hash
    res = Hash.new { |h, v| h[v] = [] }
    current_organization.delegations.includes(:delegator, :delegate).each { |d| res[d.delegator] << d }
    res
  end
end
