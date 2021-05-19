class AuthenticationsController < ApplicationController
  before_action :redirect_to_demo_path
  before_action :ensure_logged_out, only: %i[new verify create multiple create_with_user]
  before_action :find_authentication, only: %i[create verify]
  before_action :ensure_authentication_session, only: %i[multiple create_with_user]
  before_action :set_organization
  skip_before_action :session_timeout

  def new; end

  def verify
    @authentication.create_token
  end

  def create
    if @authentication.authenticate(params[:token])
      save_authentication_session(@authentication)

      return redirect_to(login_path, alert: "Your phone/email has been recently changed. Please use your new phone/email to login.") if @authentication.users.blank?
      return redirect_to(multiple_authentications_path) if @authentication.users.length > 1

      login @authentication.users.first
      redirect_back_or_to route_current_user
    else
      flash.now[:alert] = 'Invalid code. Try again.'
      render :verify
    end
  end

  def destroy
    path = current_user&.organization.present? ? organization_path(current_user.organization.slug) : root_path

    logout

    redirect_to path
  end

  def multiple
    @users = @authentication.users.includes(:organization).order("id ASC")
  end

  def create_with_user
    user = @authentication.users.find_by(id: params[:user_id])

    if user
      login user
      redirect_back_or_to route_current_user
    else
      flash.now[:alert] = 'Invalid login selected. Try again.'
      render :multiple
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id]) if params[:organization_id].present?
  end

  def find_authentication
    return redirect_to(login_path) if params[:login_handler].blank?
    @authentication = Authentication.for(params[:login_handler])

    if @authentication.blank?
      flash.now[:alert] = 'Phone/Email not found'
      render :new
    end
  end
end
