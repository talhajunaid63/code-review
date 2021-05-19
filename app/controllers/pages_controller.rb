class PagesController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :hide_nav, only: []

  def homepage
    if logged_in?
      redirect_to main_route
    else
      redirect_to login_path
    end
  end

  def system
    authorize current_user, policy_class: PagePolicy
  end

  def login
  end

  def contact
    set_return_to
  end

  def rmg
    rmg = Organization.find(4)
    if rmg
      redirect_to organization_path(rmg)
    else
      redirect_to '/'
    end
  end

  def updates
    @hide_nav = true
  end

  private

  def hide_nav
    @hide_nav = true
  end

  def set_return_to
    @return_to = root_path
    @return_to = session[:return_to] if session[:return_to]
    @return_to = current_user.route if current_user
    @return_to
  end
end
