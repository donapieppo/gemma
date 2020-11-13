FactoryBot.define do
  factory :booking do |b|
    user
    thing
    organization { thing.organization }
    recipient    { nil }
    date         { GEMMA_TEST_NOW }
  end
end


