FactoryBot.define do
  factory :user do
    sequence(:upn) { |n| "upn#{n}" }
    name { "Pippo" }
    surname { "Pluto" }
  end
end
