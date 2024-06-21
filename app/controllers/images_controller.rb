class ImagesController < ApplicationController
  before_action :resize_image, only: [:create]

  def index
    authorize Image
    @images = Image.includes(thing: :organization).order("things.organization_id")
  end

  def create
    @thing = current_organization.things.find(params[:thing_id])
    image = @thing.images.new(image_params)
    image.user_id = current_user.id

    authorize image

    if image.save
      flash[:notice] = "L'immagine è stata salvata"
    else
      flash[:error] = "Non è stato possibile salvere l'allegato. #{image.errors.first.inspect}"
    end

    redirect_to edit_thing_path(@thing)
  end

  def destroy
    @image = Image.find(params[:id])
    authorize @image
    @image.photo.purge
    @image.delete
    redirect_to edit_thing_path(@image.thing_id)
  end

  private

  def image_params
    params[:image].permit(:photo)
  end

  def resize_image
    if params[:image][:photo]
      path = params[:image][:photo].tempfile.path
      image = ImageProcessing::Vips.source(path)
      result = image.resize_to_limit!(600, 600)
      params[:image][:photo].tempfile = result
    end
  end
end
