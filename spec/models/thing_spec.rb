require 'rails_helper'

describe Thing do

  let (:thing_build) { FactoryBot.build(:thing, organization: organization, group: group) }
  let (:thing) { FactoryBot.create(:thing) }
  let (:organization) { FactoryBot.create(:organization) }
  let (:group) { FactoryBot.create(:group, organization: organization) }

  it "is valid with correct params" do
    expect(thing_build).to be_valid
  end

  it "when created total is 0" do
    expect(thing.total).to eq 0
  end

  it "does not create two equal things in same organization" do
    thing2 = FactoryBot.build(:thing, name: thing.name, organization: thing.organization, group: FactoryBot.create(:group, organization: thing.organization))
    expect(thing2).not_to be_valid
    expect(thing2.errors[:name]).to include("L'articolo esiste già.")
  end

  it "does create two equal things in different organizations" do
    group2 = FactoryBot.create(:group)
    thing2 = FactoryBot.build(:thing, group: group2, name: thing.name, organization: group2.organization)
    expect(thing2).to be_valid
  end

  it "#create_deposits accepts array of location ids" do
    location = FactoryBot.create(:location, organization: thing.organization)
    expect(thing.create_deposits([location.id])).to be
  end

  it "#create_deposits creates new deposit" do
    location = FactoryBot.create(:location, organization: thing.organization)
    thing.create_deposits([location.id])
    expect(thing.deposits.map(&:location_id)).to include(location.id)
  end

  it "does not create a deposit with location in other organization" do
    l = FactoryBot.create(:location)
    expect { thing.create_deposits([l.id]) }.to raise_error(DmUniboCommon::MismatchOrganization)
  end

  it "does not create a things in group that belongs to other organization" do
    group2 = FactoryBot.create(:group)
    expect { FactoryBot.create(:thing, group: group2, organization: thing.organization) }.to raise_error(DmUniboCommon::MismatchOrganization)
  end

  it "does permit to destroy a newly created thing" do
    expect(thing.destroy).to be
  end

  it "does not permit to delete if there are loads associated" do
    load = FactoryBot.create(:load)
    expect(load.thing.destroy).to be_falsey
    expect(load.thing.errors[:base].first).to match(/Ci sono carichi e scarichi associati a questo articolo/)
  end
end

