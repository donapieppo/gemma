module ThingHelper
  def thing_actions_enabled?
    policy(current_organization).book? || policy(current_organization).unload? 
  end

  # cliccabile se ci sono oggetti o se si ha diritto di fare qualcosa
  def thing_actions_url(thing)
    if thing_actions_enabled?
      (policy(current_organization).book? && ! policy(current_organization).unload?) ? new_thing_booking_path(thing) : new_thing_unload_path(thing) 
    else
      '#'
    end
  end

  def thing_image(thing)
    if thing && (i = thing.images.first) && i.photo.attached?
      content_tag :div, class: 'image centered my-3' do
        image_tag i.photo
      end
    end
  end
end
