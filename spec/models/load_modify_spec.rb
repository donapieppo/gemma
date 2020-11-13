require 'rails_helper'

describe Load do

  let (:load)    { FactoryBot.create(:load) }
  let (:thing)   { load.thing }
  let (:deposit) { load.moves.first.deposit }

  it "does permit to change load date so that unload stays positive" do
    FactoryBot.create(:unload, thing: thing, date: load.date + 2.day, numbers: { deposit.id => -1 })

    expect {load.aggiorna(date: load.date + 1.day)}.not_to raise_error
  end

  it "does not permit to change load date so that unload becomes negative" do
    FactoryBot.create(:unload, thing: thing, numbers: { deposit.id => 1 - deposit.actual })

    expect {load.aggiorna(date: load.date + 1.day)}.to raise_error(Gemma::NegativeDeposit)
  end

  it "does permit to change load number so that unload becomes 0" do
    actual = deposit.actual
    FactoryBot.create(:unload, thing: thing, numbers: { deposit.id => 1 - actual })

    expect(load.aggiorna(numbers: { deposit.id => actual - 1 })).to be
    expect(deposit.reload.actual).to eq(0)
  end

  it "does permit to change load number so that unload becomes negative" do
    actual = deposit.actual
    FactoryBot.create(:unload, thing: thing, numbers: { deposit.id => 1 - actual })

    expect {load.aggiorna(numbers: { deposit.id => actual - 2 })}.to raise_error(Gemma::NegativeDeposit)
  end

  it "does create a valid single load, destroy it and actual and total are be correct" do
    expect(load.destroy).to be
    expect(deposit.reload.actual).to eq 0 
    expect(thing.reload.total).to eq 0
  end

  it "should be possible to change number in same deposit" do
    expect(load.aggiorna({numbers: { deposit.id => 123 }})).to be

    expect(deposit.reload.actual).to eq 123
    expect(thing.reload.total).to eq 123
  end
end



