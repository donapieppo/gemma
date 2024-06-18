module PriceMethods
  extend ActiveSupport::Concern

  def fix_prices(p, add_iva)
    p[:price_int] = BigDecimal(p[:price_int])
    p[:price_dec] = BigDecimal(p[:price_dec])
    add_iva = BigDecimal(add_iva)

    price = (p[:price_int] * 100 + p[:price_dec])
    if price > 0 && add_iva > 0
      price *= ((100 + add_iva) / 100)
      p[:price_int] = (price / 100).to_i
      p[:price_dec] = (price - ((price / 100).to_i * 100)).to_i
    end
    p
  end
end
