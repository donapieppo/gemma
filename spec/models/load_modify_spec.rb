require 'rails_helper'

describe Load do

  before(:each) do
    @num     = 40 # numero casuale :-)

    @now     = GEMMA_TEST_NOW
    @thing   = FactoryBot.create(:thing, :with_deposits)
    @deposit = @thing.deposits.first

    @ok = { organization_id: @thing.organization_id,
            numbers:         { @deposit.id => @num },
            thing_id:        @thing.id,
            user_id:         FactoryBot.create(:user).id,
            recipient:       nil, 
            date:            @now, 
            ddt_id:          FactoryBot.create(:ddt, organization: @thing.organization, date: @now - 1.day).id }
  end

  it "does not permit to change load date so that unload becomes negative" do
    load = Load.create(@ok)
    FactoryBot.create(:unload, thing: @thing, numbers: { @deposit.id => 1 - @num })

    expect {load.aggiorna(date: @now + 1.day)}.to raise_error(Gemma::NegativeDeposit)
  end

  it "does permit to change load number so that unload becomes 0" do
    load = Load.create(@ok)
    FactoryBot.create(:unload, thing: @thing, numbers: { @deposit.id => 1 - @num })

    expect(load.aggiorna(numbers: { @deposit.id => @num - 1 })).to be
    expect(@deposit.reload.actual).to be 0
  end

  it "does permit to change load number so that unload becomes negative" do
    load = Load.create(@ok)
    # ne resta uno
    FactoryBot.create(:unload, numbers: { @deposit.id => 1 - @num }, thing: @thing )

    expect {load.aggiorna({numbers: { @deposit.id => @num - 3 }})}.to raise_error(Gemma::NegativeDeposit)
  end

  it "does create a valid single load, destroy it and actual and total are be correct" do
    actual = @deposit.actual
    load = Load.create(@ok)
    expect(load.destroy).to be
    expect(@deposit.reload.actual).to eq actual 
    expect(@thing.reload.total).to eq 0
  end

  it "should be possible to change number in same deposit" do
    actual = @deposit.actual
    load = Load.create(@ok)
    expect(load.aggiorna({numbers: { @deposit.id => 123 }})).to be

    expect(@deposit.reload.actual).to eq (actual + 123)
    expect(@thing.reload.total).to eq 123
  end

  it "should be possible to change deposit" do 
    actual = @deposit.actual
    load = Load.create(@ok)
    expect(load.aggiorna({numbers: { @thing.deposits[1].id => 12 }})).to be

    expect(@deposit.reload.actual).to eq actual
    expect(@thing.deposits[1].reload.actual).to eq 12
    expect(@thing.reload.total).to eq 12
  end
end



