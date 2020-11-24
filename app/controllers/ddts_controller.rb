class DdtsController < ApplicationController
  before_action :set_ddt_and_check_permission, only: [:show, :edit, :update, :destroy]

  def index
    authorize Ddt
    @ddts = current_organization.ddts.includes(:supplier).order('number desc')
    if params[:supplier_id]
      @supplier = Supplier.find(params[:supplier_id])
      @ddts = @ddts.where(supplier_id: @supplier.id)
    end
  end

  def search_cia
    authorize Ddt
    @ddts = []
    if params[:ncia] && params[:ycia]
      @titolo_ricerca = "Risultati ricerca per Riferimento Cia #{params[:ycia]} / #{params[:ncia]}"
      @ddts = current_organization.operations
                                  .where('ncia = ? AND ycia = ?', params[:ncia], params[:ycia])
                                  .includes(:ddt)
                                  .map(&:ddt).uniq
      render action: :index                             
    end
  end

  def search
    authorize Ddt
    @ddts = current_organization.ddts.includes(:supplier).order('date desc')

    # ricerca nome fornitore
    if params[:supplier]
      @titolo_ricerca = "Risultati ricerca per fornitore: #{params[:supplier]}"
      @ddts = @ddts.where('suppliers.name LIKE ?', "%#{params[:supplier]}%").references(:supplier)
    end

    # ricerca con un singolo fornitore
    if params[:supplier_id]
      @ddts = @ddts.where('supplier_id = ?', params[:supplier_id].to_i)
    end

    # ricerca libera su name
    if params[:like]
      @ddts = @ddts.where('name LIKE ?', "%#{params[:like]}%")
    end

    # ricerca libera su record ddt (chiamato number)
    if params[:number]
      @titolo_ricerca = "Risultati ricerca numero #{params[:number].to_i}"
      @ddts = @ddts.where('ddts.number = ?', params[:number].to_i)
    end

    # ricerca tra date '15/01/2015'
    if params[:datainizio] && params[:datafine]
      inizio = Date.parse(params['datainizio'])
      fine   = Date.parse(params['datafine'])
      @titolo_ricerca = "Risultati ricerca data tra #{inizio} e #{fine}"
      @ddts = @ddts.where('ddts.date >= ? AND ddts.date <= ?', inizio, fine)
    end

    render action: :index
  end

  # mostriamo i load relativi al Ddt (servono solo agli amministratori)
  def show
    @loads = @ddt.loads.includes(:thing).order('things.name').all
  end

  def new
    if params[:supplier_id]
      @supplier = Supplier.find(params[:supplier_id])
      @ddt      = @supplier.ddts.new(organization_id: current_organization.id)
      authorize @ddt
    else
      skip_authorization
      redirect_to suppliers_path(for: 'ddt') and return
    end
  end

  # la sessione :from_thing_id serve nel caso si volesse creare un ddt mentre ci si trova nel
  # caricare un thing. Lo usiamo solo qui'...
  def create
    @supplier = Supplier.find(params[:supplier_id])
    @ddt = current_organization.ddts.new(ddt_params)
    @ddt.supplier_id = @supplier.id

    authorize @ddt

    if @ddt.save
      flash[:notice] = "Documento registrato correttamente con RECORD N. #{@ddt.number}."

      if session[:from_thing_id]
        from_thing_id = session[:from_thing_id].to_i
        session[:from_thing_id] = nil
        redirect_to new_thing_load_path(from_thing_id) and return 
      else
        flash[:notice] += 'Per caricare gli articoli relativi a questo ddt/fattura scegliere la Categoria dal menu.'
        redirect_to ddts_path and return 
      end
    else
      @supplier = @ddt.supplier
      render action: 'new'
    end
  end

  def edit
    @supplier = @ddt.supplier
  end

  def update
    params.delete(:number)      # non si può cambiare
    params.delete(:supplier_id) # non si può cambiare

    if @ddt.update(ddt_params)
      redirect_to ddts_path, notice: 'Il documento è stato aggiornato.'
    else
      @supplier = @ddt.supplier
      render action: 'edit'
    end
  end

  def destroy
    if @ddt.loads.any?
      redirect_to ddt_path(@ddt), alert: 'Non è possibile cancellare il documento perchè ha carichi associati che devono prima essere cancellati.'
    else
      @ddt.destroy or raise "errore interno su ddt #{ddt.id}"
      redirect_to ddts_path, notice: 'Il documento è stato cancellato.'
    end
  end

  private

  def ddt_params
    params.require(:ddt).permit(:number, :gen, :name, :date)
  end

  def set_ddt_and_check_permission
    @ddt = current_organization.ddts.includes(:supplier).find(params[:id])
    authorize @ddt
  end
end
