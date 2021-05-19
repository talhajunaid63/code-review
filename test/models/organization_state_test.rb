require "test_helper"

describe OrganizationState do

  setup do
    @organization = organizations(:uvo_health)
  end
  let(:organization_state) { OrganizationState.new }

  it "must be valid" do
    value(organization_state).must_be :valid?
  end

  it 'is primary state for organization' do
    primary_organization_state = organization_states(:primary_state)

    primary =  @organization.organization_states.is_primary.first
    assert_equal(primary, primary_organization_state)
  end

  it 'non primary state for organization' do
    non_primary_state_1 = organization_states(:non_primary_state_1)
    non_primary_state_2 = organization_states(:non_primary_state_2)
    non_primary_state_3 = organization_states(:non_primary_state_3)

    all_non_primary_state = @organization.organization_states.non_primary
    assert_equal(all_non_primary_state, [non_primary_state_1, non_primary_state_2, non_primary_state_3])
  end

  it "when organization state is primary" do
    non_primary_state_1 = organization_states(:non_primary_state_1)

    data = non_primary_state_1.is_primary?
    assert_equal(data, false)
  end

  it "when organization state is not primary" do
    primary_organization_state = organization_states(:primary_state)

    data = primary_organization_state.is_primary?
    assert_equal(data, true)
  end
end