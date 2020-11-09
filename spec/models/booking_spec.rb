require 'rails_helper'

describe Booking do
  let (:load)    { FactoryBot.create(:load) }
  let (:thing)   { load.thing }
  let (:deposit) { load.moves[0].deposit }

  it "does set correct actual" do
    actual = deposit.reload.actual
    booking = FactoryBot.create(:booking, thing: load.thing, numbers: { deposit.id => - 1 })
    expect(deposit.reload.actual).to eq(actual - 1)
  end

  it "does set correct total" do
    # FIXME ci vuole thing.reload :-(
    actual = thing.reload.total
    booking = FactoryBot.create(:booking, thing: load.thing, numbers: { deposit.id => - 1 })
    expect(thing.reload.total).to eq(actual - 1)
  end

  it "turns in an Unload after #confirm" do
    booking = FactoryBot.create(:booking, thing: load.thing, numbers: { deposit.id => - 1 })
    expect(booking.confirm).to be
    expect(Operation.find(booking.id)).to be_kind_of(Unload)
  end
end
