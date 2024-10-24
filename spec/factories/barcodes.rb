FactoryBot.define do
  factory :barcode do
    sequence(:name) { |n| "SpecBarcode#{n}" }

    association :thing
    organization { thing.organization }
  end
end
