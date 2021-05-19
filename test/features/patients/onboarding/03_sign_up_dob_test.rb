require 'test_helper'

feature "SignUpDobTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @organization = organizations(:uvo_health)
    @patient = patients(:patient_44)
    stubs_text_message_send_text
  end

  scenario 'Valid date of birth form submits and saves' do
    authenticate_user(@patient, @patient.phone)

    visit organization_patient_build_path(:dob, organization_id: @organization.slug, patient_id: @patient.id)

    expect(page).must_have_content('Date of Birth')

    within("form#edit_patient_#{@patient.id}") do
      fill_in 'patient_date_of_birth', with: '02/06/1985'
    end

    find('.btn-theme-primary').click
    expect(page).must_have_content('Time Zone')
    @patient.reload
    assert_equal '02/06/1985', @patient.date_of_birth
  end
end
