FactoryBot.define do
  factory :ddt do
    sequence(:number) {|n| "999#{n}".to_i }
    name        { 'SpecDdt' }
    gen         { 'ddt' }
    date        { GEMMA_TEST_NOW - 3.days }

    supplier
    organization
  end
end


