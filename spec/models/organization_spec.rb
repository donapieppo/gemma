require 'rails_helper'

describe Organization do

  it "should create FIRST_LOCATION and FIRST_GROUP with activate" do
    organization = FactoryBot.create(:organization)
    organization.activate

    organization = Organization.find(organization.id)
    expect(organization.groups.size).to    eq(1)
    expect(organization.locations.size).to eq(1)

    expect(organization.groups.first.name).to    eq(FIRST_GROUP)
    expect(organization.locations.first.name).to eq(FIRST_LOCATION)
  end

end
