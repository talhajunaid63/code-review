class OrgSetups::TokenConfirmationsController < ApplicationController
  before_action :set_login_handler

  def new
    @token_confirmation_form = OrgSetup::TokenConfirmation.new(login_handler: @login_handler)
  end

  def create
    @token_confirmation_form = OrgSetup::TokenConfirmation.new(token_confirmation_params)
    if @token_confirmation_form.process
      admin = signed_up_user
      session[:user_id] = admin.id
      session[:login_handler] = admin.phone || admin.email
      session.delete(:signed_up_user_id)
      @org_setup = OrgSetup.create!(step: 1, org_admin_id: admin.id)
      redirect_to OrganizationOnboardingService.new(@org_setup).next_step
    else
      flash.now[:alert] = @token_confirmation_form.errors.full_messages.first
      render :new
    end
  end

  private

  def token_confirmation_params
    params.require(:org_setup_token_confirmation).permit(:token, :login_handler)
  end

  def set_login_handler
    @login_handler = params[:login] || params[:org_setup_token_confirmation][:login_handler]
  end

  def signed_up_user
    User.find session[:signed_up_user_id]
  end
end
