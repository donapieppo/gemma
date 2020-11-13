#Factory.sequence :load_number do |n|
#  "999#{n}".to_i
#end

FactoryBot.define do
  factory :unload do 
    user
    thing
    organization { thing.organization }
    recipient    { nil }
    date         { GEMMA_TEST_NOW }
  end
end


