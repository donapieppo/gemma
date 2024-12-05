Given(/^one booking (\w+) by a user of (\d+) in date (\d+)-(\d+)$/) do |name, number, date_day, date_month|
  @user = create(:user)
  @book ||= {}
  @book[name] = create(:booking, user:         @user,
    organization: @organization,
    thing_id:     @thing.id,
    date:         "2009-#{date_month}-#{date_day}",
    numbers:      {@organization.deposits.first.id => -1 * number.to_i})
end

When(/^Admin confirms the book (\w+)$/) do |name|
  @book[name].confirm
end

Then(/^there is no more booking by the user$/) do
  expect(@user.bookings.count).to eq(0)
end

Then(/^there is an unload of (\d+) by the user today$/) do |number|
  unload = @user.unloads.first
  expect(unload.date).to eq(Date.today)
  expect(unload.number).to eq(-1 * number)
end
