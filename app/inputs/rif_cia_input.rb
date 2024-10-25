class RifCiaInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    oggi = Date.today.year.to_i
    years_cia = [oggi, oggi - 1, oggi - 2]
    @builder.input_field(:ycia, collection: years_cia, include_blank: false, class: "form-select w-auto d-inline me-1") << " / " <<
      @builder.input_field(:ncia, size: 6, class: "ms-1 form-control w-auto d-inline")
  end
end
