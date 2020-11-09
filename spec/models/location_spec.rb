require 'rails_helper'

describe Location do

  before(:each) do
    @organization = FactoryBot.create(:organization)
    @ok = { :name => 'location di prova', 
            :organization_id => @organization.id }
  end

  it "should not create a valid location without :name or :organization_id" do
    expect(Location.new(@ok.merge({:name => nil}))).not_to be_valid
    expect(Location.new(@ok.merge({:organization_id => nil}))).not_to be_valid
  end

  it "should create a valid location, save id and create the same location in another organization" do
    location = Location.new(@ok)
    expect(location.save).to be
    o = FactoryBot.create(:organization)
    location = Location.new(@ok.merge({:organization_id => o.id}))
    expect(location).to be_valid
  end

  it "should create a valid location, save id and not be able to recreate in the same organization" do
    location = Location.new(@ok)
    expect(location.save).to be
    location = Location.new(@ok)
    expect(location).not_to be_valid
  end

  it "should create a valid location, save id and then delete" do
    location = Location.new(@ok)
    expect(location.save).to be
    expect(location.destroy).to be
  end

  it "should non be possible to delete with a thing inside" do
    location = Location.new(@ok)
    group    = FactoryBot.create(:group, :organization => @organization)
    expect(location.save).to be
    t = Thing.new(:organization_id => @organization.id, 
                  :name => 'di prova', 
                  :description => 'di prova', 
                  :group_id => group.id, 
                  :minimum => 0)
    expect(t.save).to be
    t.create_deposits([location.id])
    expect(location.destroy).not_to be
  end

end

