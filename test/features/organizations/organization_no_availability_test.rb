require "test_helper"

feature "OrganizationNoAvailabilityTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @organization = organizations(:uvo_health)
    @org_admin = org_admins(:org_admin_jeanette)
    @patient = patients(:patient_45)

    remove_availables_time_from_organization
    stubs_text_message_send_text
  end

  scenario "System displays a warning and disables new visit form" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit new_organization_visit_order_path(@organization)
    expect(page).must_have_content("No Availability")
    expect(page).must_have_content("There are no available time slots to schedule this visit")
    assert find_field('visit_order_patient_id', {disabled: true})
  end

  scenario "System Removes set up a new visit option from patient's dashboard" do
    authenticate_user(@patient, @patient.phone)
    dashboard_organization_patient_path(@patient.organization, @patient)
    expect(page).wont_have_content("It's simple and quick")
  end

  def remove_availables_time_from_organization
    AvailableTime.where(user_id: @organization.providers.pluck(:id)).destroy_all
  end

end
