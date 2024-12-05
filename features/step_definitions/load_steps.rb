Given(/^one load (\w+) of (\d+) in date (\d+)-(\d+)$/) do |name, number, date_day, date_month|
  @load ||= {}
  @load[name] = create(:load, organization: @organization,
    thing_id: @thing.id,
    ddt: @ddt,
    date: "2009-#{date_month}-#{date_day}",
    numbers: {@organization.deposits.first.id => number})
end

# FIXME refactor with up
Given(/^one load (\w+) of (\d+) in date (\d+)-(\d+) with price (\d+)$/) do |name, number, date_day, date_month, price|
  @load ||= {}
  @load[name] = create(:load, organization: @organization,
    thing_id: @thing.id,
    ddt: @ddt,
    date: "2009-#{date_month}-#{date_day}",
    price: price,
    numbers: {@organization.deposits.first.id => number})
end

When(/^I change the date of (\w+) to (\d+)-(\d+)$/) do |name, date_day, date_month|
  @load[name].aggiorna(date: "2009-#{date_month}-#{date_day}")
rescue Gemma::NegativeDeposit
  @load[name].errors.add(:base, Gemma::NegativeDeposit.new.to_s)
end

When(/^I change the number of (\w+) to (\d+)$/) do |name, number|
  @load[name].aggiorna(numbers: {@organization.deposits.first.id => number})
rescue Gemma::NegativeDeposit
  @load[name].errors.add(:base, Gemma::NegativeDeposit.new.to_s)
end

When(/^I change the price of (\w+) to (\d+)$/) do |name, price|
  @load[name].aggiorna(price: price)
end

When(/^I destroy the load (\w+)$/) do |name|
  @load[name].destroy
rescue Gemma::NegativeDeposit
  @load[name].errors.add(:base, Gemma::NegativeDeposit.new.to_s)
end

Then(/^I get error in base of load (\w+): (.*)$/) do |name, error|
  expect(@load[name].errors[:base].first).to match(/#{error}/)
end

Then(/^I dont get error in base of load (\w+)$/) do |name|
  expect(@load[name].errors[:base].first).not_to be
end

Then(/^I get error in date of load (\w+): (.*)$/) do |name, error|
  expect(@load[name].errors[:date].first).to match(/#{error}/)
end

Then(/^date of (\w+) is (\d+)-(\d+)$/) do |name, date_day, date_month|
  expect(Load.find(@load[name].id).date).to eq(DateTime.parse("2009-#{date_month}-#{date_day}"))
end

Then(/^number of (\w+) is (\d+)$/) do |name, number|
  expect(Load.find(@load[name].id).number).to eq(number.to_i)
end

Then(/^there is no more load (\w+)$/) do |name|
  lambda { Operation.find(@load[name].id) }.should raise_error(ActiveRecord::RecordNotFound)
end
