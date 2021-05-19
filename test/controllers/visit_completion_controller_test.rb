require "test_helper"
feature "VisitCompletionControllerTest" do
  include AuthenticationHelper
  include PaymentHelper
  include OpenTokHelper
  include TextMessageHelper

  setup do
    stubs_open_tok_create_session
    stubs_open_tok_generate_token
    @org_admin = org_admins(:org_admin_michael)
    @org = organizations(:rmg)
    @org_payment_required = organizations(:uvo_health)
    @visit = visits(:visit_1)
    @visit.update_open_tok_data
    @provider = providers(:provider_carissa)
    @provider_payment_required = providers(:provider_janet)
    @visit_payment_required = visits(:visit_8)
    @visit_payment_required.update_open_tok_data
    @patient_payment_required = @visit_payment_required.patient
    stubs_text_message_send_text
  end

  scenario "Completion no payment requried does not process payment" do
    authenticate_user(@provider, @provider.phone)
    visit organization_visit_path(@org, @visit)
    click_button "End Visit"
    expect(page).must_have_content("Enter Visit Room")
    @visit.reload
    assert_equal 7, @visit.status
    assert @visit.stripe_invoice.blank?
  end

  scenario "Completion payment requried processes payment" do
    authenticate_user(@provider_payment_required, @provider_payment_required.phone)
    visit organization_visit_path(@org_payment_required, @visit_payment_required)
    patient_add_payment(@patient_payment_required)
    StripeMock.start
    click_button "End Visit"
    StripeMock.stop
    expect(page).must_have_content("Enter Visit Room")
    @visit_payment_required.reload
    assert_equal 10, @visit_payment_required.status
    assert @visit_payment_required.stripe_invoice.present?
  end

end
