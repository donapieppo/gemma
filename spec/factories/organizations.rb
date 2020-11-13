FactoryBot.define do
  factory :organization do 
    sequence(:code) { |n| "A.SpecO#{n}" }
    sequence(:name) { |n| "A.SpecO#{n} Name" }
    description     { "SpecTest" }
    pricing         { true }
  end
end


