require "rails_helper"

describe Ddt do
  let(:ddt) { FactoryBot.create(:ddt) }
  let(:ddt_build) { FactoryBot.build(:ddt, organization: organization, supplier: supplier) }
  let(:organization) { FactoryBot.create(:organization) }
  let(:supplier) { FactoryBot.create(:supplier) }

  it "can be valid :-)" do
    expect(ddt_build).to be_valid
  end

  it "is not valid without name" do
    ddt_build.name = nil
    expect(ddt_build).not_to be_valid
  end

  it "is not valid with gen = ldslkdkl" do
    ddt_build.gen = "ldslkdkl"
    expect(ddt_build).not_to be_valid
  end

  it "is not valid without existing supplier" do
    ddt_build.supplier_id = 111
    expect(ddt_build).not_to be_valid
  end

  it "is not valid with date after today" do
    ddt_build.date = Date.today + 1.day
    expect(ddt_build).not_to be_valid
    expect(ddt_build.errors[:date]).to include("La data non può essere successiva a oggi.")
  end

  it "does not change number when updates name and gen" do
    ddt.gen = "fatt"
    ddt.name = "di prova due"
    expect(ddt.save).to be
    expect(ddt.reload.number).to eq(ddt.number)
  end

  it "gets a new number unique in structure"
  context "Given a ddt" do
    it "another ddt with same attributes in the other year is valid" do
      expect(FactoryBot.build(:ddt, ddt.attributes.merge(id: nil, date: (ddt.date - 366.days)))).to be_valid
    end

    it "another ddt with same attributes in the same year is not valid" do
      # FIXME fallisce il 1,2,3 gennaio :-)
      expect(FactoryBot.build(:ddt, ddt.attributes.merge(id: nil, date: (ddt.date - 2.days)))).not_to be_valid
    end
  end
end
