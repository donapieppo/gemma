class PermissionsController < ApplicationController
  def index
    if current_user.current_organization_authlevel >= 50
      @permissions = current_organization.permissions.includes(:user)
      skip_authorization
    else
      redirect_to home_path, error: "No access."
    end
  end

  def new
    if current_user.current_organization_authlevel >= 50
      @permission = current_organization.permissions.new
      skip_authorization
    else
      redirect_to home_path, error: "No access."
    end
  end

  def create
    authlevel = params[:permission][:authlevel].to_i
    skip_authorization

    # only in dm_unibo_common permission can create read admins
    if (current_user.current_organization_authlevel >= 50 && authlevel < 50) || current_user.is_cesia?
      @permission = current_organization.permissions.new(
        user_upn: params[:permission][:user_upn],
        authlevel: params[:permission][:authlevel]
      )

      if @permission.save
        # FIXME FIXME FIXME brutto.
        # Da rifare il cache di auth
        current_user.reload_authlevels_cache!
        redirect_to permissions_path, notice: "Abilitazione correttamente creata."
      else
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to home_path, error: "No access."
    end
  end

  def destroy
    @permission = DmUniboCommon::Permission.find(params[:id])
    skip_authorization

    if current_user.current_organization_authlevel >= 50
      if @permission.destroy
        flash[:notice] = "OK."
      else
        flash[:error] = "Non è stato possibile eliminare l'abilitazione."
      end
      redirect_to permissions_path, notice: "Abilitazione revocata."
    else
      redirect_to home_path, error: "No access."
    end
  end
end
