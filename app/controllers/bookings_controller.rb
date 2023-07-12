class BookingsController < ApplicationController
  before_action :set_thing, only: [:new, :create]
  before_action :set_booking_and_check_permission, only: [:destroy, :edit, :update, :confirm]

  def index
    authorize Booking
    if policy(current_organization).give?
      @books = current_organization.bookings.includes(:user, :recipient, :thing, :lab).order("date")
      if params[:user_id]
        @user = User.find(params[:user_id])
        @books = @books.where(user: @user).or(@books.where(recipient: @user))
      elsif params[:thing_id]
        @thing = Thing.find(params[:thing_id])
        @books = @books.where(thing: @thing)
      elsif params[:barcode]
        @barcode = current_organization.barcodes.includes(:thing).where(name: params[:barcode]).first
        @thing = @barcode.thing if @barcode
        @books = @barcode ? @books.where(thing_id: @barcode.thing_id) : []
      end
      @delegations = delegations_hash
      @cache_users = User.bookers_in_cache(current_organization.id)
    else
      @books = current_user.bookings
        .where(organization_id: current_organization.id)
        .includes(:user, :recipient, :thing, :lab)
    end
    @books = @books.to_a

    render :mylist unless policy(current_organization).give?
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
    params[:booking][:numbers] = {params[:booking].delete(:deposit_id) => params[:booking].delete(:number).to_i * -1}

    @book = @thing.bookings.new(booking_params)

    @book.organization_id = current_organization.id
    @book.user_id = current_user.id
    @book.date = Date.today

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
      @book.number = @book.number * -1
      @delegators = current_user.get_delegators(current_organization.id).to_a.push(current_user)
      render action: :new, status: :unprocessable_entity
    end
  end

  # can confirm or edit
  # if edit we delete the booking and show a precompiled new unload
  # FIXME don't care for deposits, chooses the operator
  def edit
    @thing = @book.thing

    # deleghe. Se non delega nessuno l'operatore scarica per l'utente stesso
    # se c'e' delega il delegato sparisce e l'operatore fa lo scarico.
    # @unload.recipient_id = @book.user_id unless @book.recipient_id
    h = {recipient_id: (@book.recipient_id or @book.user_id),
         date: @book.date, # try to keep because of prices different in different times
         lab_id: @book.lab_id,
         note: @book.note,
         number: @book.number * -1}
    @book.destroy

    # can't create before @boo destroy or checks app/model/operation fails
    @unload = @thing.unloads.new(h)

    render "unloads/new"
  end

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

  private

  def booking_params
    params[:booking].permit(:note, :recipient_id, :lab_id, numbers: params[:booking][:numbers].try(:keys))
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
