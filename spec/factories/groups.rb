FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    organization
  end
end

