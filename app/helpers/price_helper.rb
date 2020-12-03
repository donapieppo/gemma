module PriceHelper
  def cents_to_euro(cents)
    '%.2f €' % (cents.to_f / 100)    
  end

  def print_price(price)
    '%.2f €' % (price.to_f / 100)
  end

  def show_future_prices(thing)
    if thing.organization.pricing && thing.future_prices
      fp = thing.future_prices.select { |fp| fp[:p] > 0 }.map { |fp| "#{fp[:n]} a #{print_price(fp[:p])}" }.join(', ')
      fp.blank? ? '' : "disponibili #{fp}"
    else
      ''
    end
  end

  def show_price_origins(operation)
    if operation.price.to_i > 0
      operation.price_operations.select { |po| po[:p] > 0 }.map { |po| "#{po[:n]} da #{po[:desc]} (#{print_price(po[:p])})" }.join(', ')
    else
      ''
    end
  end
end
