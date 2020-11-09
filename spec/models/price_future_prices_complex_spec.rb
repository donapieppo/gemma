require 'rails_helper'

RSpec::Matchers.define :int_eq do |expected|
  match do |actual|
    actual.to_i == expected.to_i
  end
end

describe Load do
  let (:thing)   { FactoryBot.create(:thing, :with_deposits) }
  let (:deposit) { thing.deposits.first }

  context "given load yesterday of 50 peaces for 100 euro" do 
    let (:yesterday_load) { FactoryBot.create(:load, thing: thing, numbers: { deposit.id => 50 }, price: 100, date: load.date - 1.day) }

    context "given a today load of 3 things for 300 cents" do 
      let (:load) { FactoryBot.create(:load, thing: thing, numbers: { deposit.id => 3 }, price: 300) }

      context "given unload tomorrow of 2 thing" do
        let (:tomorrow_unload) { FactoryBot.create(:unload, numbers: { deposit.id => -2 }, thing: thing, date: load.date + 1.day) }

        it "unload tomorrow of 2 pieces has the yesterday price" do
          yesterday_price = yesterday_load.price/yesterday_load.numbers[deposit.id]
          expect(tomorrow_unload.reload.price).to int_eq 2*yesterday_price
        end

        it "if yesterday load is destroyed unload get modifications according to today price" do
          yesterday_load
          tomorrow_unload
          today_price = load.price/load.numbers[deposit.id]
          yesterday_load.destroy
          expect(tomorrow_unload.reload.price).to int_eq 2*today_price
        end

        it ".aggiorna to 20 pieces yesterday_load changes tomorrow_unload price to " do
          yesterday_load.aggiorna(numbers: { deposit.id => 20 })
          expect(tomorrow_unload.reload.price).to int_eq 2*(100/20)
        end
      end

      context "given unload tomorrow of 52 thing" do
        let (:tomorrow_unload) { FactoryBot.create(:unload, numbers: { deposit.id => -52 }, thing: thing, date: load.date + 1.day) }

        it "unload tomorrow has the price 100 + 200" do
          yesterday_price = yesterday_load.price/yesterday_load.numbers[deposit.id]
          expect(tomorrow_unload.reload.price).to int_eq (100 + 200)
        end

        it ".aggiorna to 30 pieces on today load changes tomorrow_unload price to " do
          yesterday_load
          tomorrow_unload
          load.aggiorna(numbers: { deposit.id => 30 })
          expect(tomorrow_unload.reload.price).to int_eq (100 + 2 *(300/30))
        end
      end
    end
  end
end
