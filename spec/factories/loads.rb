FactoryBot.define do
  factory :load do
    transient do
      number_of_deposits { 2 }
      number_in_deposits { [4, 6] }
    end

    user
    thing { FactoryBot.create(:thing, :with_deposits, number_of_deposits: number_of_deposits) }
    organization { thing.organization }
    ddt { FactoryBot.create(:ddt, organization: thing.organization) }

    numbers {
      n = {}
      thing.deposits.each_with_index do |deposit, i|
        n[deposit.id] = number_in_deposits[i]
      end
      n
    }

    recipient_id { nil }
    date { GEMMA_TEST_NOW }
  end
end
