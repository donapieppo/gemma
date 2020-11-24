class SuppliersController < ApplicationController
  before_action :set_supplier_and_check_permission, only: [:edit, :update]

  def index
    authorize Supplier
    # possiamo ricevere con un GET da loads/new il valore remember_thing_id
    # che dobbiamo ricordarci per tornare dopo l'inserimento del ddt
    session[:from_thing_id] = params[:remember_thing_id].to_i if params[:remember_thing_id] 

    @initial = params[:in] ? params[:in][0, 1] : 'a'

    @suppliers = Supplier.where(['name REGEXP ?', "^#{@initial}"]).order('name asc').to_a

    # per cosa ci serve vedere i suppliers?
    @for = params[:for]
    if @for == 'ddt'
      @title = 'Registrazione nuovo ddt/fattura: scelta del fornitore'
    else
      @title = 'Fornitori'
    end
    respond_to do |format|
      format.html
      format.js 
    end
  end

  def new
    @supplier = Supplier.new
    authorize @supplier
    render layout: false if modal_page
  end

  def create
    @supplier = Supplier.new(supplier_params)
    authorize @supplier
    if @supplier.save
      redirect_to suppliers_path, notice: 'Il fornitore è stato creato.' 
    else
      render action: :new
    end
  end

  def edit
    render layout: false if modal_page
  end

  def update
    if @supplier.update(supplier_params)
      redirect_to suppliers_path, notice: 'Il fornitore è stato aggiornato.'
    else
      render action: :edit
    end
  end

  def find
    authorize Supplier
    @for = params[:for]

    if params[:supplier] && params[:supplier][:string] && params[:supplier][:string].length >= 2
      @suppliers = Supplier.where(['name LIKE ?', "%#{params[:supplier][:string]}%"]) 
    elsif params[:supplier] && params[:supplier][:pi] && params[:supplier][:pi].length >= 2
      pi = params[:supplier][:pi].to_i
      @suppliers = Supplier.where(['pi LIKE ?', "%#{pi}%"])
    else
      flash[:error] = 'Raffinare i parametri di ricerca.'
      redirect_to suppliers_path
      return
    end
    @supppliers = @suppliers.order('suppliers.name').to_a
    flash[:notice] = 'Non ci sono fornitori che soddisfino la ricerca' if @suppliers.empty?
    render action: :index
  end

  private

  def supplier_params
    params[:supplier].permit(:name, :pi)
  end

  def set_supplier_and_check_permission
    @supplier = Supplier.find(params[:id])
    authorize @supplier
  end
end
