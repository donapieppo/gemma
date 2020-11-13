FactoryBot.define do
  factory :location do 
    sequence(:name) { |n| "SpecLocation_#{n}" }

    organization
  end
end


