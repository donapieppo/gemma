require "rails_helper"

describe Delegation do
  let(:delegator) { FactoryBot.create(:user) }
  let(:delegate) { FactoryBot.create(:user) }
  let(:organization) { FactoryBot.create(:organization) }

  before(:each) do
    @ok = {organization_id: organization.id, delegator_id: delegator.id, delegate_id: delegate.id}
  end

  it "should permit to create a delegation and its delegate delegators should include delgator" do
    delegation = Delegation.new(@ok)
    expect(delegation.save).to be
  end

  it "should permit to create a delegation and its delegate delegators should include delgator" do
    delegation = Delegation.create(@ok)
    expect(delegation.delegate.delegators).to include(delegator)
  end
end
