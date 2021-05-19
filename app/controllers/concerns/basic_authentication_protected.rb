module BasicAuthenticationProtected
  extend ActiveSupport::Concern

  included do
    before_action :basic_authentication
  end

  def basic_authentication
    authenticate_or_request_with_http_basic do |username, password|
      username == ApplicationConfig["HTTP_BASIC_AUTH_USERNAME"] && password == ApplicationConfig["HTTP_BASIC_AUTH_PASSWORD"]
    end
  end

end
