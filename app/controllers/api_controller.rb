class ApiController < ApplicationController
  include Response
  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

   def not_found
    render json: { message: "Not Found" }, status: 404
  end

  def throw_500(message)
      render json: {
        message: message,
      }, status: 500
  end

  def throw_4XX(message, status)
    render json: {
      message: message,
    }, status: status
  end

  def throw_400(message)
    throw_4XX(message, 400)
  end

  def throw_401(message = 'Unauthorized')
    throw_4XX(message, 401)
  end

  def throw_404(message)
    throw_4XX(message, 404)
  end

  def api_return(message, status)
    render json: {
      message: message,
    }, status: status
  end

  def api_errors_return(message, errors, status)
    render json: {
      message: message,
      errors: errors,
    }, status: status
  end

  def api_resource_return(message, resource, status)
    render json: {
      message: message,
      resource: resource,
    }, status: status
  end

  def ensure_org_admin_or_ownership(resource)
    return true if @user.type == "OrgAdmin" && @user.organization_id == resource.organization_id
    return true if @user.id == resource.id
    throw_401
  end

   def ensure_org_admin
    return true if @user.type == "OrgAdmin"
    throw_401
  end

  def return_user_from_auth_token
    return org_admin_from_authenticated_organization if @authenticated_organization
    @auth_token = request.headers['AUTH_TOKEN'] || request.headers['HTTP_AUTH_TOKEN']
    if @auth_token
      @user = User.find_by_authentication_token(@auth_token)
    else
      false
    end
  end

  def app_token_valid?
    token = request.headers["HTTP_APP_TOKEN"] || request.headers["APP_TOKEN"]
    token == ApplicationConfig["APP_TOKEN"] ? true : false
  end

  def org_admin_from_authenticated_organization
    @user = @authenticated_organization.org_admins.first
    return @user if @user
    render json: {
      message: 'Before being able to interact with UvoHealth API you need to add an Admin to your Organization',
    }, status: 401
  end

  def organization_app_token_valid?
    token = request.headers["HTTP_APP_TOKEN"] || request.headers["APP_TOKEN"]
    @authenticated_organization = Organization.find_by(api_token: token)
  end

  def authorize_app
    if app_token_valid? || organization_app_token_valid?
      true
    else
    render json: {
      message: 'Unauthorized',
      }, status: 200
    end
  end

  def auth_user
    @user = return_user_from_auth_token
    if @user
      @user
    else
      @error = true
      throw_500(@message ? @message : 'A user for given auth_token not found')
    end
  end

  def ensure_org_admin
    unless @user.type == "OrgAdmin"
      api_return("Authenticated Org Admin is required", 401)
    end
  end

end
