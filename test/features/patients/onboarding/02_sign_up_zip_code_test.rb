require 'test_helper'

feature 'SignUpZipCodeTest' do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @organization = organizations(:uvo_health)
    @patient = patients(:patient_44)
    stubs_text_message_send_text
  end

  scenario 'Valid zip code form submits and saves' do
    authenticate_user(@patient, @patient.phone)

    visit organization_patient_build_path(:zip, organization_id: @organization.slug, patient_id: @patient.id)

    expect(page).must_have_content('What\'s Your Zip Code?')

    within("form#edit_patient_#{@patient.id}") do
      fill_in('patient_zip', with: '93456')
    end

    click_button 'Save & Continue'
    expect(page).must_have_content('Date of Birth')
    @patient.reload
    assert_equal "93456", @patient.zip
  end
end
