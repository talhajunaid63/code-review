require "test_helper"
class Organizations::OrganizationStatesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include AuthenticationHelper

  setup do
    @organization = organizations(:uvo_health)
    @org_admin = org_admins(:org_admin_jeanette)

    sign_in @org_admin
  end

  test 'test_index' do
    get :index, params: { organization_id: @organization.id }
    assert_response :success   
  end

  test "Create organization state from organization state create" do
    state = states(:state_arizona)
    count_before = OrganizationState.all.count


    post :create, params: {
      organization_id: @organization.id,
      organization: {
        state_ids: @organization.states.map(&:id).append(state.id)
      }
    }, xhr: true

    assert count_before < OrganizationState.all.count
  end

  test "find organization state from organization state create" do
    state = states(:state_alaska)
    count_before = OrganizationState.all.count

    post :create, params: {
      organization_id: @organization.id,
      organization: {
        state_ids: [state.id]
      }
    }, xhr: true

    assert count_before = OrganizationState.all.count
  end
end