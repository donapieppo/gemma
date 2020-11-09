require 'rails_helper'

RSpec::Matchers.define :int_eq do |expected|
  match do |actual|
    actual.to_i == expected.to_i
  end
end

describe Load do
  let (:num)     { 11 }
  let (:money)   { 87.0 }
  let (:thing)   { FactoryBot.create(:thing, :with_deposits) }
  let (:deposit) { thing.deposits.first }

  before(:each) do
    thing.organization.update_attribute(:pricing, true)
  end

  context "given a today load of num things for money cents" do 
    let (:load) { FactoryBot.create(:load, thing: thing, numbers: { deposit.id => num }, price: money) }

    it ".price returns money" do
      expect(load.price).to int_eq money
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
      expect(load.reload.price).to int_eq money
    end

    it ".aggiorna num to 20 does change .thing.get_price to money/20" do
      load.aggiorna(numbers: { deposit.id => 20 })
      # [{:id=>175, :n=>20, :p=>4.35}]:Array
      expect(load.thing.reload.future_prices.first[:p]).to int_eq money/20
    end

    context "given unload tomorrow of 2 thing" do
      let (:tomorrow_unload) { FactoryBot.create(:unload, numbers: { deposit.id => -2 }, thing: thing, date: load.date + 1.day) }

      it "it has price 2*money/num" do
        expect(tomorrow_unload.reload.price).to int_eq 2*money/num
      end

      it "changing load price to 200 changes price of the unload to 2*200/num" do
        load.aggiorna(price: 200)
        expect(tomorrow_unload.reload.price).to int_eq 2*200.0/num
      end
    end
  end
end



