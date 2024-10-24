require "rails_helper"

RSpec::Matchers.define :int_eq do |expected|
  match do |actual|
    actual.to_i == expected.to_i
  end
end

describe Load do
  let(:thing) { FactoryBot.create(:thing, :with_deposits) }
  let(:deposit) { thing.deposits.first }

  before(:each) do
    thing.organization.update_attribute(:pricing, true)
  end

  it "does not create a valid load with negative price" do
    unvalid_load = FactoryBot.build(:load, price: -10)
    unvalid_load.organization.update_attribute(:pricing, true)
    expect(unvalid_load).not_to be_valid
    expect(unvalid_load.errors[:price]).to include("Il prezzo deve essere positivo.")
  end

  it ".price_int is 21 with price 2112" do
    expect(FactoryBot.build(:load, price: 2112).price_int).to eq 21
  end

  it ".price_dec is 12 with price 2112" do
    expect(FactoryBot.build(:load, price: 2112).price_dec).to eq 12
  end
end
