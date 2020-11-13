FactoryBot.define do
  factory :price do
    user
    thing        { FactoryBot.create(:thing, :with_deposits) }
    organization { thing.organization }
    recipient_id { nil }
    price        { 100 }

    date         { GEMMA_TEST_NOW }
  end
end



