require "rails_helper"

describe Unload do

  before(:each) do
    @now = GEMMA_TEST_NOW
    @load = FactoryBot.create(:load)
    @thing = @load.thing
    @moves = @load.moves

    @user = FactoryBot.create(:user)
    @recipient = FactoryBot.create(:user)

    @ok = {organization_id: @load.organization.id,
           numbers: {@moves[0].deposit_id => 1 - @moves[0].number},
           thing_id: @load.thing_id,
           user_id: @user.id,
           recipient_id: @recipient.id,
           date: @now + 2.days}
  end

  it "does create a valid unload" do
    expect(Unload.new(@ok)).to be_valid
  end

  it "does set actual" do
    actual = @moves[0].deposit.actual
    Unload.create(@ok)
    expect(@moves[0].deposit.reload.actual).to eq(actual - @moves[0].number + 1)
  end

  it "does set total" do
    actual = @thing.reload.total
    Unload.create(@ok)
    expect(@thing.reload.total).to eq(actual - @moves[0].number + 1)
  end

  it "validates numbers" do
    expect(Unload.new(@ok.merge(numbers: nil))).not_to be_valid
  end

  it "validates user_id" do
    expect(Unload.new(@ok.merge(user_id: nil))).not_to be_valid
  end

  it "validates positive number" do
    expect(Unload.new(@ok.merge(numbers: {@moves[0].deposit_id => +3}))).not_to be_valid
  end

  it "validates :deposit_id" do
    expect(Unload.new(@ok.merge(numbers: {1123454 => 10}))).not_to be_valid
  end

  it "does not permit to unload more than we have" do
    expect(lambda { Unload.create(@ok.merge(numbers: {@moves[0].deposit_id => -1 - @moves[0].number})) }).to raise_error(Gemma::NegativeDeposit)
  end

  it "does create a move with date after today" do
    expect(Unload.new(@ok.merge(date: (Time.now + 1.day)))).not_to be_valid
  end

  # FIXME come fare un mock di dsa_search
  it "does give error with recipient_upn = 'pip.pi@unibo.it'" do
    u = Unload.new(@ok)
    u.recipient_upn = "pip.pi@unibo.it"
    expect(u).not_to be_valid
  end

  #it "should be ok recipient_upn = 'pip.pi@unibo.it' instead of recipient_id" do
  #  u = Unload.new(@ok)
  #  u.recipient_id = nil
  #  u.recipient_upn = @recipient.upn
  #
  #  expect(u).to be_valid
  #end
end
