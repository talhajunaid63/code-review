class OrgSetups::SignUpsController < ApplicationController
  before_action :redirect_to_demo_path
  before_action :ensure_logged_out

  def new
    @sign_up_form = OrgSetup::SignUp.new
  end

  def create
    @sign_up_form = OrgSetup::SignUp.new(sign_up_params)
    if @sign_up_form.process
      session[:signed_up_user_id] = @sign_up_form.user_id
      redirect_to new_org_setup_token_confirmation_path(login: @sign_up_form.login_handler)
    else
      flash.now[:alert] = @sign_up_form.errors.full_messages.first
      render :new
    end
  end

  private

  def sign_up_params
    params.require(:org_setup_sign_up).permit(:login_handler)
  end
end
