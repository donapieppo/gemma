class UnloadsController < ApplicationController
  before_action :get_thing, only: [:new, :create]
  before_action :get_unload_and_check_permission, only: [:edit, :update, :destroy, :signing]
  before_action :get_last_recipient, only: [:new]

  # current_user unloads
  def index
    authorize Unload
    @unloads = current_organization.unloads
                                   .includes(:thing, :user)
                                   .where(type: 'Unload')                 
                                   .where('recipient_id = ? OR user_id = ?', current_user.id, current_user.id)
                                   .where('YEAR(date) = ?', Date.today.year)
                                   .order('date desc')
  end

  def new
    if @thing.total == 0 
      skip_authorization
      u = policy(current_organization).manage? ? new_thing_load_path(@thing) : group_things_path(@thing.group_id)
      redirect_to u, alert: 'Non sono presenti oggetti da scaricare.'
      return
    else
      @unload = @thing.unloads.new(organization_id: current_organization.id)
      @unload.date = Date.today # FIXME vedi inizialize con date_afternoon
      authorize @unload
      @cache_users = User.all_in_cache(current_organization.id)
    end
  end

  def create
    # solo bidelli o amministratori possono settare data (e nel caso la mettiamo con usta)
    params[:unload][:date] = Date.today unless policy(current_organization).give? 

    # ricorda che per avere permit la key deve essere string
    params[:unload][:numbers] = { params[:unload].delete(:deposit_id) => (params[:unload].delete(:number).to_i * -1) }

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
      @cache_users = User.all_in_cache(current_organization.id)
      @unload.number = @unload.number * -1
      render action: :new
    end
  end

  def edit
    @numero = @unload.number.to_i * -1  

    # non ci possiamo arrivare. il link non e' attivo con 1
    ( @numero == 1 ) and raise "Lo scarico è già al minimo. È possibile solo cancellarlo."
    # non dovrebbe mai essere successo
    ( @unload.moves.size > 1 ) and raise "Ci sono scarichi su più ubicazioni."

    @single_move = @unload.moves.first
  end

  # possiamo solo togliere oggetti dall'unload (ovvero aggiungere oggetti)
  # si puo' pensare che i controlli nell'update siano nel model (se esiste l'ip dell'unload => solo ridurre il number)
  def update
    old_number = @unload.number.to_i 
    ( old_number < 0 ) or raise "Numero originale errato. Contatta amministratore programma di scarico."
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

  #
  # %%%% signing (ricevuta da stampare)  %%%%
  #

  def signing
    render layout: false  # e' un popoup
  end

  private 

  def get_unload_and_check_permission
    @unload = current_organization.unloads.includes(:user).find(params[:id])
    authorize @unload
  end

  def get_thing
    @thing = current_organization.things.includes(:locations).find(params[:thing_id])
  end

  def send_unload_mails
    # da utente stesso
    if (current_organization.sendmail == 'y' && @unload.recipient !~ /\w\.\w/)
      OperationMailer.notify_unload(@unload.reload).deliver_now
    end

    # verso recipient
    # solo se settato nella pagina compilata dall'admin
    if (params[:sendmail] && @unload.recipient)
      OperationMailer.notify_unload_to_recipient(@unload.reload).deliver_now
    end

    # sottoscorta
    if (@thing.total + @unload.number < @thing.minimum && current_organization.adminmail =~ /\w/) 
      OperationMailer.notify_minimum(@unload).deliver_now
    end
  end

  def unload_params
    pars = [:number, :date, :ddt_id, :note, :price, numbers: params[:unload][:numbers].try(:keys)]
    pars << :recipient_upn if policy(current_organization).give?
    params[:unload].permit(pars)
  end

  def get_last_recipient
    @last_recipient_upn = session[:last_recipient_upn].blank? ? current_organization.last_recipient_upn : session[:last_recipient_upn]
  end

end

