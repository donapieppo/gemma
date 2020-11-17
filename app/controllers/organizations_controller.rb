class OrganizationsController < ApplicationController
  skip_before_action :set_booking_organization, only: [:booking_accept, :start_booking] 

  # only cesia from _menu
  def index
    authorize Organization
    @organizations    = Organization.order(:name)
    @counts           = Operation.group(:organization_id).count
    @this_year_counts = Operation.where('YEAR(date) = YEAR(NOW())').group(:organization_id).count
    @arch_counts      = ArchOperation.group(:organization_id).count
  end

  def edit
    authorize current_organization

    @ddts = current_organization.ddts.order('date desc').limit(10)
    @operations = current_organization.operations.includes(:thing, :user).order('date desc').limit(10)

    q = "SELECT count(*) from arch_operations WHERE organization_id =#{current_organization.id.to_i}"
    @arch_number = ApplicationRecord.connection.execute(q).first[0]
    @operations_number = current_organization.operations.where('YEAR(date) = YEAR(NOW())').count

    @permissions_hash = Hash.new {|hash, key| hash[key] = [] }

    current_organization.permissions.includes(:user).order('authlevel desc, users.upn asc').references(:user).each do |permission|
      @permissions_hash[permission.authlevel] << permission
    end
  end

  def update
    authorize current_organization
    if current_organization.update(organization_params)
      redirect_to current_organization_edit_path, notice: 'La Struttura è stata modificata.'
    else
      render action: :edit
    end
  end

  def choose_organization
    authorize Organization
  end

  def booking_accept
    authorize Organization
  end

  def start_booking
    authorize Organization
    session[:booking] = current_organization.id
    redirect_to root_path(__org__: current_organization.code)
  end

  def destroy
    authorize current_organization
    current_user.is_cesia? or raise "NO access"
    if current_organization.destroyable?
      current_organization.destroy
      flash[:notice] = "Organizzazione cancellata."
    else
      flash[:error] = "Operazione non possibile."
    end
    redirect_to organizations_path
  end

  private

  # except for cesia can edit current_organization
  def get_organization_and_check_permission
    @organization = current_user.is_cesia? ? Organization.find(params[:id]) : current_organization
  end

  def organization_params
    p =  [:pricing, :sendmail, :adminmail]
    p += [:name, :description, :booking] if current_user.is_cesia?
    params[:organization].permit(p)
  end

end
