require 'rails_helper'

describe BatchUnload do

  # user, organization, thing, p
  before(:each) do
    @now       = GEMMA_TEST_NOW
    @num       = [ 10, 20 ]
    @load      = FactoryBot.create(:load, number_in_deposits: @num)
    @thing     = @load.thing
    @thing.reload
    @deposit   = @thing.deposits.first.reload
    @user      = FactoryBot.create(:user)
    @recipient = FactoryBot.create(:user)
    @organization = @thing.organization

    @p = { numbers: { @deposit.id => -1 }, 
           date: @now,
           recipient_upn: "a@unibo.it, nicola.arcozzi@unibo.it" }
  end

  it "does create a valid batch_unloads" do
    expect(BatchUnload.new(@user, @organization, @thing, @p)).to be_valid
  end

  it "with number > deposit.actual not valid" do
    @p[:numbers] = { @deposit.id => (@deposit.actual + 1) * -1 }
    expect(BatchUnload.new(@user, @organization, @thing, @p)).not_to be_valid
  end
end
