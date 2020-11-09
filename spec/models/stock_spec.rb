require 'rails_helper'

describe Stock do

  # gli mettiamo un ddt tanto per confonderlo...
  before(:each) do
    @num     = 40 # numero casuale :-)

    @thing   = FactoryBot.create(:thing, :with_deposits)
    @ddt     = FactoryBot.create(:ddt, organization: @thing.organization)
    @deposit = @thing.deposits.first
    @total   = @thing.total

    @user      = FactoryBot.create(:user)
    @recipient = FactoryBot.create(:user)

    @ok = { organization_id: @thing.organization_id,
            numbers: { @deposit.id => @num },
            thing_id: @thing.id,
            user_id: @user.id,
            recipient_id: nil, 
            date: Date.today } 
  end

  #
  # CREATE
  #
  it "should create a valid giacenza iniziale on single deposit thing and actual and total should be correct" do
    s = Stock.new(@ok)
    expect(s.save).to be

    expect(Deposit.find(@deposit.id).actual).to eq(@deposit.actual + @num)
    expect(@thing.reload.total).to eq(@num)

    s = Stock.find(s.id)
    expect(s.is_stock?).to be
    expect(s.ddt_id).not_to be
  end

  it "should create a valid giacenza iniziale and operation should be right" do
    s = Stock.new(@ok)
    expect(s.save).to be

    operation = Operation.find(s.id)
    expect(operation).to be_an_instance_of Stock
    expect(operation.number).to     eq(@num)
    expect(operation.moves.size).to eq(1)
  end

  it "should not create a second giacenza iniziale" do
    s = Stock.new(@ok)
    expect(s.save).to be

    s = @thing.stocks.build(@ok)
    expect(s).not_to be_valid
  end
end


