require 'rails_helper'

describe Takeover do

  before(:each) do
    @num     = 40 # numero casuale :-)

    @now     = GEMMA_TEST_NOW
    @thing   = FactoryBot.create(:thing, :with_deposits)
    @ddt     = FactoryBot.create(:ddt, :organization => @thing.organization, :date => @now - 1.day)
    @deposit = @thing.deposits.first

    @user      = FactoryBot.create(:user)
    @recipient = FactoryBot.create(:user)

    @ok = { :organization_id => @thing.organization_id,
            :numbers   => { @deposit.id => @num },
            :thing_id  => @thing.id,
            :user_id   => @user.id,
            :recipient_id => @recipient.id,
            :date      => @now }
  end

  it "should create a valid presaconsegna on single deposit thing and actual and total should be correct" do
    pc = Takeover.new(@ok)
    expect(pc.save).to be

    o = Operation.find(pc.id)
    expect(o).to be_an_instance_of Takeover
    expect(o.number).to eq(@num)
    expect(o.is_a?(Takeover)).to be

    expect(Deposit.find(@deposit.id).actual).to eq(@deposit.actual + @num)
    expect(Thing.find(@thing.id).total).to eq(@num)
  end

  it "should not create a presaconsegna without recipient" do
    pc = Takeover.new(@ok.merge(:recipient => nil))
    expect(pc.save).not_to be
  end

end
