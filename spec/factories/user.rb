FactoryBot.define do
  factory :user do 
    sequence(:upn) {|n| "upn#{n}"}
    name    { "Pippo" }
    surname { "Plut" }
  end
end



