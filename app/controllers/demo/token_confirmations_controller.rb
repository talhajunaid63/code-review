class Demo::TokenConfirmationsController < ApplicationController
  before_action :set_login_handler

  def new
    @token_confirmation_form = Demo::TokenConfirmation.new(login_handler: @login_handler)
  end

  def create
    @token_confirmation_form = Demo::TokenConfirmation.new(token_confirmation_params)
    if @token_confirmation_form.process
      demo_visit = Visit.demo_visit_for(provider)
      provider.update(organization_id: Organization.demo.id)

      redirect_to demo_visit.one_click_patient_login_visit_url(provider)
    else
      flash.now[:alert] = @token_confirmation_form.errors.full_messages.first
      render :new
    end
  end

  private

  def token_confirmation_params
    params.require(:demo_token_confirmation).permit(:token, :login_handler)
  end

  def set_login_handler
    @login_handler = params[:login] || params[:demo_token_confirmation][:login_handler]
  end

  def provider
    @provider ||= User.find session[:signed_up_user_id]
  end
end
