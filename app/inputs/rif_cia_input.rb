class RifCiaInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    oggi = Date.today.year.to_i
    years_cia = [oggi, oggi - 1, oggi - 2]
    @builder.input_field(:ycia, collection: years_cia, include_blank: false) << ' / ' <<
    @builder.input_field(:ncia, size: 6)
  end
end
