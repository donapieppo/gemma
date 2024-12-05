Given(/^organization (\S+)$/) do |organization_name|
  @organization = FactoryBot.create(:organization, name: organization_name)
end

Given(/^one organization with thing$/) do
  @thing = create(:thing, :with_deposits)
  @organization = @thing.organization
end

Given "organization has pricing on" do
  @organization.update(pricing: true).should be true
end
