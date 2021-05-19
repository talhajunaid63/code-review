require "test_helper"
feature "SignUpTokenTest" do
  include TextMessageHelper

  setup do
    stubs_text_message_send_text
    @organization = organizations(:uvo_health)
    Authentication.delete_all
  end

  scenario "A new patient can request and confirm a new sign up token code to create an account - by phone" do
    visit new_organization_sign_up_path(@organization)
    expect(page).must_have_content("create your account")
    request_token_from_new_sign_up("6613885848")
    new_patient = Patient.last
    expect(page).must_have_content("We sent a code to 6613885848")
    within("form#new_organization_sign_up_token_confirmation") do
      fill_in("organization_sign_up_token_confirmation[token]", with: Authentication.last.token)
    end
    click_button "Confirm"
    expect(page).must_have_content("Welcome")
    expect(page).must_have_content("We just need a little info before your visit.")
    expect(page).must_have_content("What's Your Zip Code?")
    assert_equal @organization.id, new_patient.organization_id
  end

  scenario "A new patient can request and confirm a new sign up token code to create an account - by email" do
    visit new_organization_sign_up_path(@organization)
    expect(page).must_have_content("create your account")
    request_token_from_new_sign_up("test_patient@fake.me")
    new_patient = Patient.last
    expect(page).must_have_content("We sent a code to test_patient@fake.me")
    within("form#new_organization_sign_up_token_confirmation") do
      fill_in("organization_sign_up_token_confirmation[token]", with: Authentication.last.token)
    end
    click_button "Confirm"
    expect(page).must_have_content("Welcome")
    expect(page).must_have_content("We just need a little info before your visit.")
    expect(page).must_have_content("What's Your Zip Code?")
    assert_equal @organization.id, new_patient.organization_id
  end

  scenario "Invalid phone number is validated" do
    visit new_organization_sign_up_path(@organization)
    expect(page).must_have_content("create your account")
    request_token_from_new_sign_up("123456")
    expect(page).must_have_content("Check login handler. US numbers or email only, phone numbers must have area code")
  end

  scenario "Invalid email is validated" do
    visit new_organization_sign_up_path(@organization)
    expect(page).must_have_content("create your account")
    request_token_from_new_sign_up("test_patient")
    expect(page).must_have_content("Check login handler. US numbers or email only, phone numbers must have area code")
  end

  def request_token_from_new_sign_up(login_handler)
    within("form#new_organization_sign_up") do
      fill_in("organization_sign_up[login_handler]", with: login_handler)
      click_button "Request Sign In Code"
    end
  end

end
