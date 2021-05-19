require 'test_helper'
class Users::UnarchiveControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include AuthenticationHelper

  def setup
    @org_admin = org_admins(:org_admin_michael)
    @organization = organizations(:rmg)
    @patient = patients(:patient_20)
  end

  test 'OrgAdmins are able to unarchive users' do
    @patient.archive!
    assert @patient.archived?
    sign_in @org_admin

    delete :destroy, params: { user_id: @patient.id }

    @patient.reload
    assert !@patient.archived?
  end

end
