class OrganizationsController < ApplicationController
  skip_before_action :after_current_user_and_organization, only: [:booking_accept, :start_booking]

  # only cesia from _menu
  def index
    authorize Organization
    @organizations = Organization.order(:code)
    @counts = Operation.group(:organization_id).count
    @this_year_counts = Operation.where("YEAR(date) > YEAR(NOW()) -1").group(:organization_id).count
    @last_year = Operation.group(:organization_id).maximum(:date)
    @arch_counts = ArchOperation.group(:organization_id).count
    @admins = DmUniboCommon::Permission.group(:organization_id).count
  end

  def edit
    authorize current_organization

    # sanitize_sql_array(["name=? and group_id=?", "foo'bar", 4])
    q = "SELECT count(*) from arch_operations WHERE organization_id = #{current_organization.id.to_i}"
    @arch_number = ApplicationRecord.connection.execute(q).first[0]

    fill_permission_hash
  end

  def update
    authorize current_organization
    if current_organization.update(organization_params)
      redirect_to current_organization_edit_path, notice: "La Struttura è stata modificata."
    else
      fill_permission_hash
      render action: :edit, status: :unprocessable_entity
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
    if current_organization.destroyable?
      current_organization.destroy
      flash[:notice] = "Organizzazione cancellata."
    else
      flash[:error] = "Operazione non possibile."
    end
    redirect_to organizations_path
  end

  private

  def organization_params
    p = [:pricing, :sendmail, :adminmail]
    p += [:name, :description, :code, :booking] if current_user.is_cesia?
    params[:organization].permit(p)
  end

  def fill_permission_hash
    @permissions_hash = Hash.new { |hash, key| hash[key] = [] }
    current_organization.permissions.includes(:user).order("authlevel desc, users.upn asc").references(:user).each do |permission|
      @permissions_hash[permission.authlevel] << permission
    end
  end
end
