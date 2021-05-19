require 'test_helper'
class Users::ArchiveControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include AuthenticationHelper

  def setup
    @org_admin = org_admins(:org_admin_michael)
    @organization = organizations(:rmg)
    @patient = patients(:patient_20)
  end

  test 'OrgAdmins are able to archive users' do
    assert !@patient.archived?
    sign_in @org_admin

    post :create, params: { user_id: @patient.id }

    @patient.reload
    assert @patient.archived?
  end

end
