class BookingsController < ApplicationController
  before_action :set_thing, only: [:new, :create]
  before_action :set_booking_and_check_permission, only: [:destroy, :confirm]

  def index
    authorize Booking

    @user = User.find(params[:user_id]) if params[:user_id]
    @thing = Thing.find(params[:thing_id]) if params[:thing_id]
    @barcode = current_organization.barcodes.includes(:thing).where(name: params[:barcode]).first if params[:barcode]

    @books = current_organization.bookings.includes(:user, :recipient, :thing, :lab)

    if policy(current_organization).give?
      if @user
        @books = @books
          .where(user: @user)
          .or(@books.where(recipient: @user))
          .order("things.name, date")
      elsif @thing
        @books = @books.where(thing: @thing).order("date")
      elsif @barcode
        @thing = @barcode.thing
        @books = @barcode ? @books.where(thing_id: @barcode.thing_id).order("date") : []
      else
        @books = @books.order("users.surname, date")
      end
      @delegations = delegations_hash
      @cache_users = User.bookers_in_cache(current_organization.id)
    else
      @books = @books.order(:date).where(user_id: current_user.id)
      render :mylist unless policy(current_organization).give?
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
    number = params[:booking].delete(:number).to_i
    deposit_id = params[:booking].delete(:deposit_id)

    @book = @thing.bookings.new(
      organization_id: current_organization.id,
      user_id: current_user.id,
      date: Date.today
    )
    @book.assign_attributes(booking_params)

    if deposit_id
      @book.numbers = {deposit_id => number * -1}
    else
      skip_authorization
      @book.number = number
      @book.errors.add(:number, "Selezionare la provenienza")
      @delegators = current_user.get_delegators(current_organization.id).to_a.push(current_user)
      render action: :new, status: :unprocessable_entity
      return
    end

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
