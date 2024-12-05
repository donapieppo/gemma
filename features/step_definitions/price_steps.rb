Then(/^future_prices of thing in load (\w+) has (\d+) at (\d+) euro in position (\d+)$/) do |load_name, number, price, position|
  fp = @load[load_name].thing.future_prices[position]
  expect(fp[:n]).to eq(number)
  expect(fp[:p]).to eq(price)
end

Then(/^future_prices of thing in load (\w+) has (\d+) elements$/) do |load_name, number|
  expect(@load[load_name].thing.future_prices.size).to eq(number)
end
