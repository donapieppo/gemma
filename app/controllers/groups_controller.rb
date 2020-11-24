class GroupsController < ApplicationController 
  before_action :set_group_and_check_permission, only: [:edit, :update, :destroy]

  def index
    @groups = current_organization.groups.order(:name)
    authorize Group
  end

  def new
    @group = current_organization.groups.new
    authorize @group
  end

  def create
    @group = current_organization.groups.new(group_params)
    authorize @group

    if @group.save
      redirect_to group_things_path(@group), notice: 'La nuova categoria è stata creata.'
    else
      render action: :new
    end
  end

  def edit 
  end

  def update
    if @group.update(name: params[:group][:name])
      redirect_to current_organization_edit_path, notice: 'La categoria è stata aggiornata.'
    else 
      render action: :update
    end
  end

  def destroy
    if @group.things.empty?
      @group.destroy 
    end
    redirect_to current_organization_edit_path, notice: 'Il gruppo è stato cancellato.'
  end

  private

  def set_group_and_check_permission
    @group = Group.find(params[:id])
    authorize @group
  end

  def group_params
    params[:group].permit(:name)
  end
end
