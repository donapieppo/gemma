FactoryBot.define do
  factory :permission, class: "DmUniboCommon::Permission" do
    user
    organization
  end
end
