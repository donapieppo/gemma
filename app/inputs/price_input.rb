class PriceInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    # o   = object.thing.deposits.map {|d| ["#{d.location} (#{d.actual} disponibili)".html_safe, d.id]}
    # dis = object.thing.deposits.map {|d| d.actual < 1 }
    # @builder.input :deposit_id, collection: o , disabled: dis, as: :radio_buttons, label: "Scegliere la provenienza"
    # template.collection_radio_buttons(:unload, :deposit_id, o, :last, :first) #{ disabled: (dep.actual < 1) })
    #  <%= o.input_field :price_int, :size => 6 %><b>,</b>
    #  <%= o.input_field :price_dec, :size => 2 %>
    #
    # load/unload/thing
    name = object.model_name.to_s.downcase
    res = int_and_dec(name)
    if name == "load" || name == "price" || name == "stock"
      res += no_iva_input + iva_inputs
    end
    res.html_safe
  end

  private

  def int_and_dec(name)
    %(
       <input class="form-select w-auto d-inline numeric integer" type="text" size="6" name="#{name}[price_int]" value="#{object.price_int}"></input>
       <b> , </b>
       <input class="form-select w-auto d-inline numeric integer numeric-cents" type="text" size="2" name="#{name}[price_dec]" value="#{object.price_dec}"></input> &euro;
    )
  end

  def no_iva_input
    %(
     <br/><label> <input name="price_add_iva" type="radio" value="0" checked="checked"/> iva inclusa</label>
    )
  end

  def iva_inputs
    IVAS.map do |iva|
      %(
        <br/>
        <label>
          <input name="price_add_iva" type="radio" value="#{iva}" />
          iva #{iva}% esclusa
        </label>
      )
    end.join("")
  end
end
