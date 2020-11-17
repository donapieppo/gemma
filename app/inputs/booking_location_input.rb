class BookingLocationInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    res = ""
    object.thing.deposits.each do |dep|
      disabled = dep.actual < 1 ? %Q|disabled="disabled"| : ""
      res += %Q|<input id="id_#{dep.id}" type="radio" value="#{dep.id}" name="booking[deposit_id]" #{disabled}></input>
                <span>#{dep.location} (#{dep.actual} disponibili)</span><br/>|.html_safe
    end
    res
  end
end

