Given(/^one unload (\w+) of (\d+) in date (\d+)-(\d+)$/) do |name, number, date_day, date_month|
  @unload ||= {}
  @unload[name] = create(:unload,
    organization: @organization,
    thing_id: @thing.id,
    date: "2009-#{date_month}-#{date_day} 12:00",
    numbers: {@organization.deposits.first.id => -1 * number.to_i})
end

Then(/^price of unload (\w+) is (\d+)$/) do |name, price|
  Unload.find(@unload[name].id).price.should == price.to_i
end
