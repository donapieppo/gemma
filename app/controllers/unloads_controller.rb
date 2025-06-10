class UnloadsController < ApplicationController
  before_action :set_thing, only: [:new, :create]
  before_action :set_unload_and_check_permission, only: [:edit, :update, :destroy, :signing]
  before_action :set_last_recipient, only: [:new, :create]

  # current_user unloads
  def index
    authorize Unload
    @unloads = current_organization.unloads
      .includes(:thing, :user)
      .where(type: "Unload")
      .where("recipient_id = ? OR user_id = ?", current_user.id, current_user.id)
      .where("YEAR(date) = ?", Date.today.year)
      .order("date desc")
  end

  def new
    if @thing.total == 0
      skip_authorization
      u = policy(current_organization).manage? ? new_thing_load_path(@thing) : group_things_path(@thing.group_id)
      redirect_to u, alert: "Non sono presenti oggetti da scaricare."
    else
      @unload = @thing.unloads.new(organization_id: current_organization.id)
      @unload.date = Date.today # FIXME: vedi inizialize con date_afternoon
      authorize @unload
    end
  end

  def create
    # lab only if didattica is on
    params[:unload].delete(:lab_id) unless params[:didattica] == "on"

    if params[:batch] == "y" && params[:unload][:recipient_upn]
      authorize :unload, :batch_unloads?
      @batch_unloads = BatchUnload.new(current_user, current_organization, @thing, unload_params)
      logger.info(@batch_unloads.inspect)
      @batch_unloads.run
      render :batch_results
      return
    end

    @unload = @thing.unloads.new(unload_params)
    @unload.organization_id = current_organization.id
    @unload.user_id = current_user.id

    authorize @unload

    begin
      res = @unload.save
    rescue Gemma::NegativeDeposit => e
      @unload.errors.add(:number, e.to_s)
      res = false
    rescue => e
      logger.info e.inspect
      @unload.errors.add(:base, e.to_s)
      res = false
    end

    if res
      flash[:notice] = "Sarico di #{@unload.number.abs} <strong>#{view_context.link_to(@thing, thing_moves_path(@thing))}</strong> registrato correttamente".html_safe
      session[:last_recipient_upn] = @unload.recipient_upn if @unload.recipient_id

      send_unload_mails

      redirect_to group_things_path(@thing.group_id, from_unload: @unload.id, from_thing: @thing.id)
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def edit
    @numero = @unload.number.to_i * -1
    # non ci possiamo arrivare. il link non e' attivo con 1
    raise "Lo scarico è già al minimo. È possibile solo cancellarlo." if @numero == 1

    @single_move = @unload.moves.first
  end

  # possiamo solo togliere oggetti dall'unload (ovvero aggiungere oggetti)
  # si puo' pensare che i controlli nell'update siano nel model (se esiste l'ip dell'unload => solo ridurre il number)
  def update
    old_number = @unload.number.to_i
    raise "Numero originale errato. Contatta amministratore programma di scarico." if old_number >= 0

    new_number = params[:unload][:number].to_i * -1 # si tratta di uno scarico...

    # ricorda che deve essere 0 > new_number > old_number
    if 0 > new_number && new_number > old_number && @unload.modify_number(new_number)
      redirect_to thing_moves_path(@unload.thing_id), notice: "Aggiornamento dello scarico effettuato."
    else
      redirect_to edit_unload_path(@unload), alert: "È solo possibile diminuire il numero di oggetti scaricati."
    end
  end

  def destroy
    if @unload.destroy
      flash[:notice] = "Lo scarico è stato eliminato."
    else
      flash[:alert] = "Non è stato possibile eliminare lo scarico"
    end
    redirect_to thing_moves_path(@unload.thing_id)
  end

  # ricevuta da stampare
  def signing
    render layout: "signing" # e" un popoup
  end

  private

  def set_unload_and_check_permission
    @unload = current_organization.unloads.includes(:user).find(params[:id])
    authorize @unload
  end

  def set_thing
    @thing = current_organization.things.includes(:locations).find(params[:thing_id])
  end

  def send_unload_mails
    # da utente stesso
    if current_organization.sendmail == "y" && @unload.recipient.nil?
      OperationMailer.notify_unload(@unload.reload).deliver_now
    end

    # verso recipient
    # solo se settato nella pagina compilata dall'admin
    if params[:sendmail] && @unload.recipient
      OperationMailer.notify_unload_to_recipient(@unload.reload).deliver_now
    end

    @thing.reload

    # sottoscorta
    if (@thing.total < @thing.minimum) && current_organization.adminmail =~ /\w/
      OperationMailer.notify_minimum(@unload).deliver_now
    end
  end

  def unload_params
    # solo bidelli o amministratori possono settare data (e nel caso la mettiamo con usta)
    params[:unload][:date] = Date.today unless policy(current_organization).give?

    # boolean if dewar (liters)
    # cold_dewar = params[:unload].delete(:cold_dewar).to_i > 0
    cold_dewar = false # default dalse per ora non si modifica

    # ricorda che per avere permit la key deve essere string
    # FIXME (else?)
    if (deposit_id = params[:unload].delete(:deposit_id))
      number = params[:unload].delete(:number).to_i

      if !cold_dewar && Rails.configuration.dewar_liters_and_hot_liters[number]
        Rails.logger.info "Hot Dewar con number=#{number.inspect}"
        number = Rails.configuration.dewar_liters_and_hot_liters[number]
      end
      params[:unload][:numbers] = {deposit_id => number * - 1}
    end

    pars = [:number, :date, :lab_id, :note, :price, numbers: params[:unload][:numbers].try(:keys)]

    pars << :recipient_upn if policy(current_organization).give?
    params[:unload].permit(pars)
  end

  def set_last_recipient
    @last_recipient_upn = session[:last_recipient_upn].blank? ? current_organization.last_recipient_upn : session[:last_recipient_upn]
  end
end
