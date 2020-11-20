class PriceCalculator
  def initialize
    @stack_of_loads = []
  end

  def add(o)
    @stack_of_loads << { operation: o, number: o.number, price: o.price.to_f / o.number }
  end

  # gets number available and single item price from FIRST in @stack_of_loads
  def get(number)
    # not enough, we consume @stack_of_loads[0] width shift
    if @stack_of_loads[0][:number] <= number
      s = @stack_of_loads.shift
      [s[:operation], s[:number], s[:price]]
    # I've got them all we keep whats left
    else
      @stack_of_loads[0][:number] -= number
      s = @stack_of_loads[0]
      [s[:operation], number, s[:price]]
    end
  end

  def remaining_stack
    @stack_of_loads.map { |s| { id: s[:operation].id, n: s[:number], p: s[:price] } }
  end

  # valore di quello che resta in magazzino
  def remaining_value
    @stack_of_loads.sum { |s| s[:number] * s[:price] }
  end
end
