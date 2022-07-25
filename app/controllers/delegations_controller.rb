class DelegationsController < ApplicationController
  def index
    authorize Delegation
    @delegations = Hash.new { |h, v| h[v] = [] }
    current_organization.delegations.includes(:delegator, :delegate).each { |d| @delegations[d.delegator] << d }
  end

  def new
    @delegation = current_organization.delegations.new
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
      flash[:notice] = 'La delega è stata assegnata.'
      redirect_to delegations_path
    else
      render action: 'new', status: :unprocessable_entity
    end
  end

  def destroy
    delegation = Delegation.find(params[:id])
    authorize delegation
    delegation.delete and redirect_to delegations_path
  end

  private

  def delegation_params
    params[:delegation].permit(:delegator_upn, :delegate_upn)
  end
end
