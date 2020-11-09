require 'rails_helper'

describe PriceCalculator do
  context "given 2 loads of 2 at 1 euro and 3 at 2 euro" do 
    let (:thing)   { FactoryBot.create(:thing, :with_deposits) }
    let (:deposit) { thing.deposits.first }
    let (:load1)   { FactoryBot.create(:load, thing: thing, numbers: { deposit.id => 2 }, price: 100) }
    let (:load2)   { FactoryBot.create(:load, thing: thing, numbers: { deposit.id => 3 }, price: 200) }

    it ".get(2) returns [load1, 2, 50]" do
      pc = PriceCalculator.new
      pc.add(load1)
      pc.add(load2)
      res = pc.get(2)
      expect(res[0]).to eq(load1)
      expect(res[1]).to eq(2)
      expect(res[2]).to eq(50.0)
    end

    it ".get(3) returns [load1, 2, 50] and then get(1) returns [load2, 1, 66.67]" do
      pc = PriceCalculator.new
      pc.add(load1)
      pc.add(load2)

      res = pc.get(3)
      expect(res[0]).to eq(load1)
      expect(res[1]).to eq(2)
      expect(res[2]).to eq(50.0)

      res = pc.get(1)
      expect(res[0]).to eq(load2)
      expect(res[1]).to eq(1)
      expect(res[2]).to eq(66.66666666666667)
    end
  end
end
