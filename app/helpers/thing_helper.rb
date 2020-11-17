module ThingHelper

  def thing_actions_enabled?
    policy(current_organization).book? || policy(current_organization).manage?
  end

  # cliccabile se ci sono oggetti o se si ha diritto di fare qualcosa
  def thing_actions_url(thing)
    if thing_actions_enabled?
      (policy(current_organization).book? && ! policy(current_organization).unload?) ? new_thing_booking_path(thing) : new_thing_unload_path(thing) 
    else
      "#"
    end
  end

  def thing_image(thing)
    if thing and i = thing.images.first
      content_tag :div, class: 'image my-2' do
        image_tag i.photo.variant(resize_to_limit: [300, 300]) 
      end
    end
  end
end
