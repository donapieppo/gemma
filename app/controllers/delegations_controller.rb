class DelegationsController < ApplicationController
  before_action :set_delegation_and_check_permission, only: [:edit, :update, :destroy]

  def index
    authorize Delegation
    @delegations = Hash.new { |h, v| h[v] = [] }
    current_organization.delegations.includes(:delegator, :delegate, :picking_point, :cost_center).each do |d|
      @delegations[d.delegator] << d
    end
  end

  def new
    @delegation = current_organization.delegations.new
    if params[:delegator_id]
      @delegation.delegator = User.find(params[:delegator_id])
    end
    authorize @delegation
  end

  def create
    @delegation = current_organization.delegations.new(delegation_params)
    authorize @delegation
    begin
      res = @delegation.save
    rescue => e
      logger.info e.inspect
      @delegation.errors.add(:base, e.to_s)
      res = false
    end

    if res
      flash[:notice] = "La delega è stata assegnata."
      redirect_to delegations_path
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @delegation.update(delegation_params)
      redirect_to delegation_path, notice: "Modifica effettuata."
    else
      render action: :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @delegation.delete and redirect_to delegations_path
  end

  private

  def set_delegation_and_check_permission
    @delegation = current_organization.delegations.find(params[:id])
    authorize @delegation
  end

  def delegation_params
    params[:delegation].permit(:delegator_upn, :delegate_upn, :cost_center_id, :picking_point_id)
  end
end
