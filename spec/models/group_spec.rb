require 'rails_helper'

describe Group do
  let(:group) { FactoryBot.create(:group) }
  let(:organization) { FactoryBot.create(:organization) }

  it "is not valid without organization" do
    expect(FactoryBot.build(:group, organization: nil)).not_to be_valid
  end

  context "Given a group" do 
    it "same group should be valid in other organizaton" do
      expect(FactoryBot.build(:group, name: group.name, organization: organization)).to be_valid
    end

    it "same group should not be valid in same organization" do
      expect(FactoryBot.build(:group, name: group.name, organization: group.organization)).not_to be_valid
    end
  end
end

