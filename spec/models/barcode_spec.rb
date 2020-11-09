require "rails_helper"

describe Barcode do

  let (:barcode)    { FactoryBot.create(:barcode) }
  let (:thing)      { barcode.thing }

  it "does create two barcodes for the same thing" do
    expect(FactoryBot.create(:barcode, thing: barcode.thing)).to be
  end

  it "does create two equal new barcodes on things in different organizations" do
    thing2 = FactoryBot.create(:thing)
    expect(FactoryBot.create(:barcode, thing: thing2)).to be
  end

  it "does not create two equal barcodes on things in the same organization" do
    thing2   = FactoryBot.create(:thing, group: thing.group, organization: thing.organization)
    barcode2 = FactoryBot.build(:barcode, name: barcode.name, thing: thing2)
    expect(barcode2).not_to be_valid
    expect(barcode2.errors[:name].first).to match(/Codice a barre già presente/)
  end

  it "does not create a new barcode with wrong organization" do
    organization = FactoryBot.create(:organization)
    expect { FactoryBot.create(:barcode, organization: organization) }.to raise_error(DmUniboCommon::MismatchOrganization)
  end
end
