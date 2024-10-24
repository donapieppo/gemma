FactoryBot.define do
  factory :thing do
    sequence(:name) { |n| "SpecThing #{n}" }

    association :group
    organization { group.organization }

    description { "Spec Thing Desc" }
    minimum { 10 }

    transient do
      number_of_deposits { 2 }
    end

    trait :with_deposits do
      after(:create) do |thing, evaluator|
        location_ids = []

        (1..evaluator.number_of_deposits).each do |i|
          location_ids << FactoryBot.create(:location, organization: thing.organization).id
        end
        # see app/models/thing.rb
        thing.create_deposits(location_ids)
      end
    end
  end
end
