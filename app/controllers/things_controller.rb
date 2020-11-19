class ThingsController < ApplicationController
  before_action :get_thing_and_check_permission, only: [:show, :edit, :update, :recalculate_prices, :destroy]
  before_action :get_all_groups_and_locations,   only: [:new, :create, :edit, :update]

  def index
    authorize Thing
    if params[:group_id] 
      @group = current_organization.groups.find(params[:group_id])
      @things = @group.things.includes(:images).order(:name).to_a
    elsif params[:location_id]
      @location = current_organization.locations.find(params[:location_id])
      @things = @location.things.includes(:images).order(:name)
      # @actuals[thing_id] = actual
      @actuals = @location.deposits.inject({}){|res, d| res[d.thing_id] = d.actual; res}
    else
      redirect_to groups_path
    end
  end

  def show
  end

  # from groups index
  def find
    authorize Thing

    @search_string = params[:search_string] || ''
    @search_string = @search_string.strip.gsub('%', '')

    if @search_string.length > 2
      @things = real_find(@search_string)

      if @things.length == 0
        redirect_to groups_path, alert: "Non sono presenti articoli che soddisfino la ricerca."
      # un solo articolo su cui si puo' operare.
      # se non possiamo operare lasciamo il view normale
      elsif @things.length == 1 and @things.first.deposits.size > 0 
        thing = @things.first
        if policy(current_organization).unload?
          redirect_to new_thing_unload_path(thing)
        elsif policy(current_organization).book?
          redirect_to new_thing_booking_path(thing)
        end
      else
        render action: :index
      end
    else
      redirect_to groups_path, alert: "Si prega di raffinare la ricerca."
    end
  end

  def new
    @group = current_organization.groups.find(params[:group_id]) 
    @thing = current_organization.things.new(group_id: @group.id, minimum: 0)
    authorize @thing
    @locations = current_organization.locations.order(:name)
    if @locations.size == 0 
      @locations = [current_organization.create_default_location]
    end
  end

  def create
    locations_array = params[:thing].delete(:location_ids)

    @thing = current_organization.things.new(thing_params)
    @locations = current_organization.locations.order(:name)

    @locations.size == 1 and locations_array = [@locations.first.id]

    authorize @thing

    # almeno una locazione e' necessaria... 
    if ( ! locations_array or locations_array.size == 0 )
      @thing.errors.add(:base, "Si prega di scegliere l'ubicazione dell'articolo.")
      render action: 'new'
      return
    end

    if @thing.save and @thing.create_deposits(locations_array)
      flash[:notice] = "L'articolo ''#{@thing}'' è stato creato."
      if params[:insert_barcodes] 
        redirect_to new_thing_barcode_path(@thing)
      else
        redirect_to group_things_path(@thing.group_id)
      end
    else
      render action: 'new' 
    end
  end

  def edit
    @barcodes = @thing.barcodes.load
    @deposits = @thing.deposits.includes(:location).order('locations.name')
    # FIXME uno a uno o uno a molti? I fornitori con codice dovrebbero essere molti in futuro. Piu' fico :-)
    @image    = Image.new
  end

  def update
    params[:thing].delete(:organization_id)
    if @thing.update(thing_params)
      redirect_to group_things_url(@thing.group_id), notice: "L'articolo è stato aggiornato"
    else
      @barcodes = @thing.barcodes
      @deposits = @thing.deposits.includes(:location).order('locations.name')
      @image    = Image.new
      render action: 'edit'
    end
  end

  def destroy
    if @thing.destroy
      redirect_to groups_path, notice: "L'articolo è stato cancellato come richiesto"
    else
      # FIXME
      error = @thing.errors.messages[:base].first
      redirect_to thing_moves_path(@thing), alert: error
    end
  end

  def inactive 
    authorize Thing
    @inactive_things = Thing.inactive(current_organization)
  end

  def recalculate_prices
    @thing.recalculate_prices
    redirect_to thing_moves_path(@thing)
  end

  private 

  # if g-1234 we return thing.find(1234)
  def real_find(stringa_ricerca)
    # see Barcode.generate(thing)
    if stringa_ricerca =~ /^g\-(\d+)$/
      [current_organization.things.find($1)]
    else
      sql_stringa = "%#{stringa_ricerca}%"
      current_organization.things.includes(:group, :barcodes, :images)
                           .order(:name)
                           .where("things.name LIKE ? OR things.description LIKE ? OR barcodes.name LIKE ?", sql_stringa, sql_stringa, sql_stringa)
                           .references(:things, :barcodes)
    end
  end

  def get_all_groups_and_locations
    @groups    = current_organization.groups.order(:name)
    @locations = current_organization.locations.order(:name)
  end

  def get_thing_and_check_permission
    @thing = current_organization.things.find(params[:id])
    authorize @thing
  end

  def thing_params
    params[:thing].permit(:name, :description, :group_id, :minimum)
  end 

end


