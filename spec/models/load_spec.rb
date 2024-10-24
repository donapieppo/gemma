require "rails_helper"

describe Load do
  let(:load) { FactoryBot.create(:load) }
  let(:thing) { load.thing }
  let(:deposit) { thing.deposits.first }

  it "is valid with valid attributes" do
    expect(load).to be_valid
  end

  it "sets correct actual in deposit" do
    expect(deposit.reload.actual).to eq(load.numbers[deposit.id])
  end

  it "sets correct total" do
    expect(thing.reload.total).to eq(load.number)
  end

  it "does raise DmUniboCommon::MismatchOrganization when create in other organization" do
    o = FactoryBot.create(:organization)
    expect { FactoryBot.create(:load, organization: o) }.to raise_error(DmUniboCommon::MismatchOrganization)
  end

  it "does not create a load without :user" do
    l = FactoryBot.build(:load, user_id: nil)
    expect(l).not_to be_valid
    expect(l.errors[:user_id]).to include("non può essere lasciato in bianco")
  end

  it "does not create a load with :number < 1" do
    l = FactoryBot.build(:load, numbers: {deposit.id => -3})
    expect(l).not_to be_valid
    expect(l.errors[:base]).to include("Il numero di oggetti da caricare deve essere positivo (ho -3)")
  end

  it "does not create a load with wrong :deposit_id" do
    l = FactoryBot.build(:load, numbers: {12223 => 10})
    expect(l).not_to be_valid
    expect(l.errors[:base]).to include("È necessario selezionare una provenienza corretta.")
  end

  it "does not create a load with wrong :ddt_id" do
    expect(FactoryBot.build(:load, ddt_id: 12223)).not_to be_valid
  end

  it "does not create a load with a date before ddt date" do
    ddt = FactoryBot.create(:ddt)
    load2 = FactoryBot.build(:load, date: (ddt.date - 10))
    expect(load2).not_to be_valid
    expect(load2.errors[:date]).to include("La data del carico non può essere anteriore alla data del ddt.")
  end

  it "does not create a move with date after today" do
    expect(FactoryBot.build(:load, date: Date.tomorrow)).not_to be_valid
  end

  it "does not create load in year different than ddt" do
    load2 = FactoryBot.build(:load)
    load2.ddt.update_attribute(:date, GEMMA_TEST_NOW - 1.year)
    expect(load2).not_to be_valid
    expect(load2.errors[:date]).to include("La data del carico non può essere in anno differente dalla data del ddt. Consigliamo di scegliere come data l'ultimo giorno dell'anno del ddt.")
  end

  it "can be deleted if has no unloads depending on it" do
    expect(load.destroy).to be
    expect { Operation.find(load.id) }.to raise_error(ActiveRecord::RecordNotFound)
    expect(Move.find_by_operation_id(load.id)).to be_nil
  end

  it "can not be deleted if has unloads depending on it" do
    actual = load.reload.number
    unload = FactoryBot.create(:unload, numbers:  {deposit.id => -1},
      thing:    thing,
      organization: thing.organization,
      date:     GEMMA_TEST_NOW + 5)

    expect { load.destroy }.to raise_error(Gemma::NegativeDeposit)
    expect(load.reload.number).to eq actual
  end
end
