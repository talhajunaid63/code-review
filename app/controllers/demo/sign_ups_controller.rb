class Demo::SignUpsController < ApplicationController
  before_action :redirect_to_demo
  before_action :ensure_logged_out

  def new
    @demo_sign_up = Demo::SignUp.new
  end

  def create
    @demo_sign_up = Demo::SignUp.new(demo_sign_up_params)

    if @demo_sign_up.process
      session[:signed_up_user_id] = @demo_sign_up.user_id
      redirect_to new_demo_token_confirmation_path(login: @demo_sign_up.login_handler)
    else
      flash.now[:alert] = @demo_sign_up.errors.full_messages.first
      render :new
    end
  end

  private

  def demo_sign_up_params
    params.require(:demo_sign_up).permit(:login_handler)
  end

  def redirect_to_demo
    return redirect_to ENV['DEMO_APP_URL'] if ENV['DEMO_APP_URL'].present?
  end
end
