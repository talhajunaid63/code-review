module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', "#{current_user.type}: #{current_user.id}"
    end

    protected

    def find_verified_user
      return User.find(session[:user_id]) if session[:user_id].present?
      return User.find_by_authentication_token(request.params[:auth_token]) if request.params[:auth_token].present?

      reject_unauthorized_connection
    end

    def session
      key = Rails.application.config.session_options.fetch(:key)
      cookies.encrypted[key]&.symbolize_keys || {}
    end
  end
end
