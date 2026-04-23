FactoryBot.define do
  factory :user do
    sequence(:upn) { |n| "upn#{n}@unibo.it" }
    name { "Pippo" }
    surname { "Pluto" }
  end
end
