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

  context "given a today load of 3 things for 300 cents" do 
    let (:load) { FactoryBot.create(:load, thing: thing, numbers: { deposit.id => 3 }, price: 300) }

    it ".price returns 300" do
      expect(load.price).to int_eq 300
    end

    it ".thing.future_prices returns array [{:id=>???, :n=>3, :p=>100.0}]" do
      expect(load.thing.future_prices).to be_kind_of(Array)
      expect(load.thing.future_prices.first[:n]).to eq(3)
      expect(load.thing.future_prices.first[:p]).to int_eq(100)
    end

    it ".aggiorna price to 100 changes price to 100" do
      load.aggiorna(price: 100)
      expect(load.reload.price).to int_eq 100
    end

    it ".aggiorna num to 20 does not change price" do
      load.aggiorna(numbers: { deposit.id => 20 })
      expect(load.reload.price).to int_eq 300
    end

    it ".aggiorna num to 20 does change .thing.future_prices 300/20" do
      load.aggiorna(numbers: { deposit.id => 20 })
      # [{:id=>175, :n=>20, :p=>4.35}]:Array
      expect(load.thing.reload.future_prices.first[:p]).to int_eq 300/20
    end

    context "given unload tomorrow of 2 thing" do
      let (:tomorrow_unload) { FactoryBot.create(:unload, numbers: { deposit.id => -2 }, thing: thing, date: load.date + 1.day) }

      it "it has price 2*(300/3)" do
        expect(tomorrow_unload.reload.price).to int_eq 200
      end

      it "changing load price to 200 changes price of the unload to 2*(200/3)" do
        load.aggiorna(price: 200)
        expect(tomorrow_unload.reload.price).to int_eq 2*200.0/3
      end
    end
  end
end

