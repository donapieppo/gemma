class BookingLocationInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    res = ""
    object.thing.deposits.each do |dep|
      input_disabled = (dep.actual < 1) ? 'disabled="disabled"' : ""
      label_disabled = (dep.actual < 1) ? 'class="text-muted"' : ""
      res += %|
        <input id="id_#{dep.id}" type="radio" value="#{dep.id}" name="booking[deposit_id]" #{input_disabled}></input>
        <label for="id_#{dep.id}" #{label_disabled}>#{dep.location} (#{dep.actual} disponibili)</label><br/>
        |.html_safe
    end
    res
  end
end
