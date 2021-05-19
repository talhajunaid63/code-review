class ApplicationController < ActionController::Base
  layout 'new_application'

  include ApplicationHelper
  include HandlesAuthentication
  include Pundit

  before_action :one_click_login
  before_action :set_active_announcements
  before_action :session_timeout
  before_action :set_paper_trail_whodunnit
  before_action :restrict_demo_user

  protect_from_forgery unless: -> { request.format.json? }

  rescue_from ActiveRecord::RecordNotFound do |exception|
    Rails.logger.info("[RecordNotFound] #{exception.message}")
    restricted_content
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    Rails.logger.info("[NotAuthorizedError] #{exception.message}")
    not_authorized
  end

  protected

  def redirect_to_demo_path
    return redirect_to demo_visit_path if ENV['DEMO_APP'].present?
  end

  def not_authorized(alert: "Sorry, You are not authorized to access this page")
    log_action Action::EVENTS[:not_authorized], current_user, nil, {url: request.path}

    return render status: 401, json: { message: alert } if request.format.json?
    redirect_to main_route, alert: alert
  end

  def log_action(event, user = nil, actionable = nil, metadata = nil)
    Action.log event, user, actionable, metadata, browser, request
  end

  def pundit_user
    CurrentContext.new(current_user, @organization)
  end

  def render_404
    redirect_to root_path, alert: 'The page you are trying to access does not exist'
  end

  def session_timeout
    return if current_user.blank?
    return current_user.active! unless current_user.idle?

    log_action Action::EVENTS[:session_timeout], current_user, current_user, {last_activity_at: current_user.last_activity_at}

    logout
    invalid_session(alert: 'You have been logged out due to inactivity and need to re-login.')
  end

  def set_organization_from_user
    @organization = Organization.find_by_slug(params[:organization_id]) || current_user.organization
  end

  def authenticate_admin_user!
    authenticate_or_request_with_http_basic("Admin") do |name, password|
      name == ApplicationConfig["ACTIVE_ADMIN_USER"] && password == ApplicationConfig["ACTIVE_ADMIN_PASSWORD"]
    end
  end

  def current_admin_user
    "Admin User"
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    end
  rescue
    session[:user_id] = nil
  end
  helper_method :current_user

  def authenticate_org_admin
    return invalid_session unless current_user
    return if current_user.administrator?

    restricted_content unless admin_or_org_admin?
  end

  def authenticate_org_admin_or_coordinator
    restricted_content unless coordinator_or_org_admin_access?(current_user)
  end

  def authenticate_administrator
    return invalid_session unless current_user
    return restricted_content unless current_user.administrator?
    false
  end

  def organization_member?
    current_user.organization_id.present? && current_user.organization_id == @organization&.id
  end

  def authenticate_administrator_or_org_admin
    return invalid_session unless current_user
    return if org_admin_privilege?(current_user)

    invalid_session
  end

  def authenticate_user
    return session_required unless current_user
    true
  end

  def admin_or_org_admin?
    organization_member? && org_admin_privilege?(current_user)
  end

  def route_current_user
    return "/browser" unless compatible_browser
    return  current_user.route if current_user
    "/"
  end

  def ensure_browser
    redirect_to  "/browser" unless compatible_browser
  end

  def compatible_browser
    return true
    return true if Rails.env.test?
    return true if browser.chrome? || browser.safari? || browser.firefox?
  end

  def ensure_logged_out
    return unless logged_in?

    redirect_to main_route
  end

  def logged_in?
    current_user.present?
  end

  def invalid_session(alert: "Sorry, You are not authorized to access this page")
    log_action Action::EVENTS[:session_invalid], current_user, nil, {url: request.path}

    return render status: 401, json: { message: alert } if request.format.json?
    redirect_to main_route, alert: alert
  end

  def session_required
    store_location
    redirect_to login_path
  end

  def restricted_content(alert: 'Sorry, You are not authorized to access this page')
    log_action Action::EVENTS[:content_restricted], current_user, nil, {url: request.path}

    redirect_back(fallback_location: main_route, alert: alert)
  end

  def main_route
    route = "/"
    route = current_user.route if current_user
    route
  end

  def ensure_permissions
    return invalid_session unless current_user

    if current_user.patient?
      if @patient
        return invalid_session unless current_user.id == @patient.id
      elsif @visit
        return invalid_session unless current_user.id == @visit.patient_id
      end
    end
  end

  def ensure_visit_permissions
    return invalid_session unless current_user

    return if current_user.administrator?

    return invalid_session unless @visit.organization_access?(current_user.organization)

    return if current_user.org_admin?
    return if current_user.patient? && @visit.patient_access?(current_user)
    return if current_user.provider? && @visit.provider_access?(current_user)
    return if current_user.coordinator? && @visit.coordinator_access?(current_user)

    return invalid_session
  end

  def ensure_search_permission
    return invalid_session unless current_user

    return if current_user.administrator?

    return invalid_session unless current_user.organization_access?(@organization)

    return if current_user.org_admin?
    return if current_user.coordinator?
    return if current_user.provider?

    invalid_session
  end

  def ensure_admin_or_ownership
    return restricted_content unless current_user
    return if current_user.administrator?
    return restricted_content if current_user.patient?

    if current_user.coordinator? && !current_user.coordinator_detail.acts_as_org_admin
      if @coordinator
        return restricted_content unless current_user.id == @coordinator.id
      else
        return restricted_content
      end
    end

    if current_user.provider? && !current_user.provider_detail.acts_as_org_admin
      if @provider
        return restricted_content unless current_user.id == @provider.id
      else
        return restricted_content
      end
    end

    if current_user.org_admin? ||
       (current_user.provider? && current_user.provider_detail.acts_as_org_admin) ||
       (current_user.coordinator? && current_user.coordinator_detail.acts_as_org_admin)
      if @organization
        return restricted_content unless current_user.organization_id == @organization.id
      end
    end
  end

  def ensure_user_not_patient
    return restricted_content unless current_user
    return restricted_content if current_user.patient?
  end

  def ensure_admin_or_org_membership
    return restricted_content unless current_user
    return if current_user.administrator?

    if @organization
      return restricted_content unless current_user.organization_id == @organization.id
    end
  end

  def ensure_and_set_patient
    return restricted_content(alert: "Sorry, You are not authorized to access this page") unless current_user.patient?
    @patient = current_user
  end

  def set_active_announcements
    @active_announcements = Announcement.active
  end

  def restrict_demo_user
    return if current_user.blank?
    return unless current_user.demo?

    logout
    return redirect_to demo_visit_path
  end
end
