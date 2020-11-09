require 'rails_helper'

RSpec::Matchers.define :int_eq do |expected|
  match do |actual|
    actual.to_i == expected.to_i
  end
end

describe Load do
  let (:thing)   { FactoryBot.create(:thing, :with_deposits) }
  let (:deposit) { thing.deposits.first }

  before(:each) do
    thing.organization.update_attribute(:pricing, true)
  end

  context "given a today load of 10 things for 200 cents" do 
    let (:load) { FactoryBot.create(:load, thing: thing, numbers: { deposit.id => 10 }, price: 200) }

    it ".price returns 200" do
      expect(load.price).to int_eq 200
    end

    it ".thing.future_prices returns array" do
      expect(load.thing.future_prices).to be_kind_of(Array)
    end

    it ".aggiorna price to 100 changes price to 100" do
      load.aggiorna(price: 100)
      expect(load.reload.price).to int_eq 100
    end

    it ".aggiorna num to 20 does not change price" do
      load.aggiorna(numbers: { deposit.id => 20 })
      expect(load.reload.price).to int_eq 200
    end

    it ".aggiorna num to 20 does change .thing.get_price to 200/20" do
      load.aggiorna(numbers: { deposit.id => 20 })
      # [{:id=>175, :n=>20, :p=>4.35}]:Array
      expect(load.thing.reload.future_prices.first[:p]).to int_eq 200/20
    end
  end
end



