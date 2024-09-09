class UnloadLocationInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    res = ""
    object.thing.deposits.each do |dep|
      disabled = (dep.actual < 1) ? 'disabled="disabled"' : ""
      res += %|<input id="id_#{dep.id}" type="radio" value="#{dep.id}" name="unload[deposit_id]" #{disabled}></input>
               <label for="id_#{dep.id}">#{dep.location} (#{dep.actual} disponibili)</label><br/>|.html_safe
    end
    res
  end
end

# o = object.thing.deposits.map {|d| ["#{d.location} (#{d.actual} disponibili)".html_safe, d.id]}
# dis = object.thing.deposits.map {|d| d.actual < 1 }
# @builder.input :deposit_id, collection: o , disabled: dis, as: :radio_buttons, label: "Scegliere la provenienza"
# template.collection_radio_buttons(:unload, :deposit_id, o, :last, :first) #{ disabled: (dep.actual < 1) }) 
