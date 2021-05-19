module HandlesAuthentication
  extend ActiveSupport::Concern
  USER_SESSION_KEY = :user_id
  AUTHENTICATION_SESSION_KEY = :authentication_id
  RETURN_TO_SESSION = :return_to

  def redirect_back_or_to(default_path, options = {})
    path = session[RETURN_TO_SESSION] || default_path
    session[RETURN_TO_SESSION] = nil
    redirect_to path, options
  end

  def store_location
    session[RETURN_TO_SESSION] = request.url
  end

  def one_click_login
    user_id = params.delete(:u)
    code = params.delete(:c)
    authentication_id = params.delete(:i)

    if user_id.present? || code.present? || authentication_id.present?
      log_action Action::EVENTS[:one_click_login_attempt], User.find_by(id: user_id), current_user, {one_click_login: {user_id: user_id, code: code, authentication_id: authentication_id}}
    end


    return if user_id.blank? || code.blank? || authentication_id.blank?

    authentication = Authentication.find_by(id: authentication_id)
    return if authentication.blank? || !authentication.authenticate(code)

    user = authentication.users.find_by(id: user_id)
    return Rails.logger.warn("User not found form authentications") if user.blank?

    login user
  end

  def login(user)
    log_action Action::EVENTS[:login_successful], user

    user.active!
    session[USER_SESSION_KEY] = user.id
  end

  def logout
    log_action Action::EVENTS[:logout], current_user

    session[USER_SESSION_KEY] = nil
    session[AUTHENTICATION_SESSION_KEY] = nil
  end

  def find_authentication_by_login_handler
    @error = false

    if handler_is_an_email? || handler_is_a_phone?
      @authentication = Authentication.for(@login_handler)
    else
      @error = true
      @message = "Check login handler. US numbers or email only, phone numbers must have area code"
    end
  end

  def handler_is_an_email?
    @login_handler =~ User::VALID_EMAIL_REGEX
  end

  def handler_is_a_phone?
    @login_handler =~ User::VALID_PHONE_NUMBER_REGEX
  end

  def set_authentication_params
    @user_type = params[:type]
    @login_handler = params[:login_handler]
    @login_handler = params[:phone] if params[:phone]
    @token = params[:token]
  end

  def clean_phone_number(phone)
    number = phone
    clean_number = number.delete("^0-9")
    if clean_number.length > 10 and clean_number.first == '1'
      clean_number = clean_number.last(10)
    end
    number = clean_number
  end

  def clean_email(email)
    clean_email = email.downcase
    clean_email
  end

  def save_authentication_session(authentication)
    session[AUTHENTICATION_SESSION_KEY] = authentication.id
  end

  def ensure_authentication_session
    @authentication = Authentication.find_by(id: session[AUTHENTICATION_SESSION_KEY])
    redirect_to login_path unless @authentication
  end
end
