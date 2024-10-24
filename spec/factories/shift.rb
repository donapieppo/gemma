FactoryBot.define do
  factory :shift do
    user
    thing { FactoryBot.create(:thing, :with_deposits) }
    organization { thing.organization }
    numbers { {thing.deposits[0].id => 1, thing.deposits[1].id => -1} }
    date { GEMMA_TEST_NOW }
  end
end
