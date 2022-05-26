class PriceInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    #o   = object.thing.deposits.map {|d| ["#{d.location} (#{d.actual} disponibili)".html_safe, d.id]}
    #dis = object.thing.deposits.map {|d| d.actual < 1 }
    #@builder.input :deposit_id, collection: o , disabled: dis, as: :radio_buttons, label: "Scegliere la provenienza"
    #template.collection_radio_buttons(:unload, :deposit_id, o, :last, :first) #{ disabled: (dep.actual < 1) }) 
    #  <%= o.input_field :price_int, :size => 6 %><b>,</b>
    #  <%= o.input_field :price_dec, :size => 2 %>
    #
    # load/unload/thing
    n = object.model_name.to_s.downcase
    res = %Q|
       <input class="form-control-inline numeric integer" type="text" size="6" name="#{n}[price_int]" value="#{object.price_int}"></input>
       <b> , </b>
       <input class="form-control-inline numeric integer numeric-cents" type="text" size="2" name="#{n}[price_dec]" value="#{object.price_dec}"></input> &euro; | 

    if n == 'load' || n == 'price' || n == 'stock'
       res += %Q|
       <input name="price_with_iva" type="radio" value="n" #{object.price ? '' : 'checked="checked"'} /> iva esclusa
       <input name="price_with_iva" type="radio" value="y" #{object.price ? 'checked="checked"' : ''} /> iva inclusa
       |
    end
    res.html_safe
  end
end


