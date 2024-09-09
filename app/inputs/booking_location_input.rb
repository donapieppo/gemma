class BookingLocationInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    res = ""
    object.thing.deposits.each do |dep|
      disabled = (dep.actual < 1) ? 'disabled="disabled"' : ""
      res += %|<input id="id_#{dep.id}" type="radio" value="#{dep.id}" name="booking[deposit_id]" #{disabled}></input>
               <label for="id_#{dep.id}">#{dep.location} (#{dep.actual} disponibili)</label><br/>|.html_safe
    end
    res
  end
end
