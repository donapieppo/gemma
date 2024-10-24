require "rails_helper"

# dipende da load, non possiamo crearlo senza in factory
describe Shift do
  let(:shift_build) { FactoryBot.build(:shift, thing: thing, organization: thing.organization, user: user) }
  let(:user) { FactoryBot.create(:user) }
  let(:load) { FactoryBot.create(:load, number_of_deposits: 2) }
  let(:thing) { load.thing }

  def numbers(x)
    {thing.deposits[0].id => -x, thing.deposits[1].id => x}
  end

  it "is valid" do
    expect(shift_build).to be_valid
  end

  it "is not valid with number zero" do
    shift_build.numbers = numbers(0)
    expect(shift_build).not_to be_valid
  end

  it "is not valid with different numbers in from and to" do
    shift_build.numbers = {thing.deposits[0].id => -10, thing.deposits[1].id => 100}
    expect(shift_build).not_to be_valid
  end

  it "is not valid with only one deposit" do
    shift_build.numbers = {thing.deposits[0].id => -10, thing.deposits[0].id => 10}
    expect(shift_build).not_to be_valid
  end

  it "raise error if number is than available" do
    expect { FactoryBot.create(:shift, thing: thing, numbers: numbers(100)) }.to raise_error(Gemma::NegativeDeposit)
  end

  it "does set correct actual" do
    a1 = thing.deposits[0].reload.actual
    a2 = thing.deposits[1].reload.actual
    shift = FactoryBot.create(:shift, thing: thing)
    expect(shift.from.reload.actual).to eq(a2 - 1)
    expect(shift.to.reload.actual).to eq(a1 + 1)
  end

  it "does set total" do
    actual_total = thing.total
    shift = FactoryBot.create(:shift, thing: thing)
    expect(thing.reload.total).to eq(actual_total)
  end

  it "shift number is zero" do
    shift = FactoryBot.create(:shift, thing: thing)
    expect(shift.number).to eq(0)
  end

  it "should create a valid shift, destroy it and actual and total should be correct" do
    a1 = thing.deposits[0].reload.actual
    a2 = thing.deposits[1].reload.actual
    actual_total = thing.reload.total
    shift = FactoryBot.create(:shift, thing: thing)

    expect(shift.destroy).to be

    expect(shift.from.reload.actual).to eq(a2)
    expect(shift.to.reload.actual).to eq(a1)
    expect(shift.thing.reload.total).to eq(actual_total)
  end
end
