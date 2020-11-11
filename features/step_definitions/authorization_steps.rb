# TODO 
# Given /^admin pippo\.pluto in organization 94 with authlevel 10$/ do
#

Given /^admin (\S+) in organization (\S+) with authlevel (\d+)$/ do |upn, organization_name, authlevel|
  organization = Organization.where(name: organization_name).first
  user = User.find_by_upn(upn) || create(:user, upn: upn)
  @admin = create(:dm_unibo_common_permission, user: user, organization_id: organization.id, authlevel: authlevel)
end

Given /^network (\S+) in organization (\S+) with authlevel (\d+)$/ do |network, organization_name, authlevel|
  organization = Organization.where(name: organization_name).first
  @admin = create(:permission, network: network, organization_id: organization.id, authlevel: authlevel)
end

When /^he logs$/ do
  @auth = Authorization.new('123.123.123.321', @admin.user)
end

Then /he has a single organization to choose/ do 
  expect(@auth.multi_organizations).to be(false)
end

Then /he has multiple organizations to choose/ do 
  expect(@auth.multi_organizations).to be(true)
end

Then /he has autlevel (\d+) on organization (\S+)$/ do |authlevel, organization_name|
  organization = Organization.where(name: organization_name).first
  expect(@auth.authlevels[organization.id]).to eq(authlevel.to_i)
end

