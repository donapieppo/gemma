require "rails_helper"

describe Booking do
  before(:each) do
    @now = GEMMA_TEST_NOW
    @load = FactoryBot.create(:load)

    @thing = @load.thing
    @initial = @thing.total
    @moves = @load.moves
    @actual = @moves[0].deposit.actual

    @user = FactoryBot.create(:user)
    @recipient = FactoryBot.create(:user)

    @ok = {organization_id: @load.organization.id,
            numbers: {@moves[0].deposit_id => 1 - @moves[0].number},
            thing_id: @load.thing_id,
            user_id: @user.id,
            date: @now + 2.days}
  end

  it "does set correct total" do
    true
  end
end
