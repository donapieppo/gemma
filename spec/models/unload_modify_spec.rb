require 'rails_helper'

describe Unload do

  before(:each) do
    @now    = GEMMA_TEST_NOW
    @load   = FactoryBot.create(:load)
    @thing  = @load.thing
    @moves  = @load.moves

    @user      = FactoryBot.create(:user)
    @recipient = FactoryBot.create(:user)

    @ok = { organization_id: @load.organization.id,
            numbers:         { @moves[0].deposit_id => 1 - @moves[0].number },
            thing_id:        @load.thing_id,
            user_id:         @user.id,
            recipient_id:    @recipient.id,
            date:            @now }
  end

  it "does create a valid unload" do
    expect(Unload.new(@ok)).to be_valid
  end

  it "when deleted all the operations are deleted" do
    unload = Unload.create(@ok)
    expect(unload.destroy).to be
    expect { Operation.find(unload.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "when deleted all the operations are deleted" do
    unload = Unload.create(@ok)
    expect(unload.destroy).to be
    expect(Move.where("operation_id = ?", unload.id)).to be_empty
  end

  it "does destroy it and actual should be correct" do
    actual = @moves[0].deposit.reload.actual
    unload = Unload.create(@ok)
    expect(unload.destroy).to be
    expect(@moves[0].deposit.reload.actual).to eq(actual)
  end

  it "does destroy it and total should be correct" do
    total = @thing.reload.total
    unload  = Unload.create(@ok)
    expect(unload.destroy).to be
    expect(@thing.reload.total).to eq total
  end

  it "should permit to modify the numbers using modify_number()" do 
    actual = Deposit.find(@moves[0].deposit_id).actual
    unload = Unload.create(@ok)
    unload.modify_number(-2)
    expect(@moves[0].deposit.reload.actual).to eq(actual - 2)
  end

  # FIXME: in teoria non viene mai chiamato un update con cambio di data 
  #        dai contollers ma.... riflettere e lasciare errore
  #it "should not modify an unload moving date before when not enough object" do
  #  pending "To be fixed maybe. intheory not used by controllers" do 
  #  unload = Unload.new(@ok)
  #   expect(unload.save).to be
  #   unload.date = @now - 1.day
  #   expect(unload.save).to be_be_falsey
  #   expect(unload.errors[:base]).to =~ /Non ci sono sufficienti elementi/
  #  end
  #end

end
