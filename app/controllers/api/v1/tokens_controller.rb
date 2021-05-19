class Api::V1::TokensController < ApiController
  before_action :authorize_app
  before_action :hack_to_make_mobile_work
  before_action :find_authentication, only: %i[request_token authenticate_token]

  def request_token
    @authentication.create_token

    render json: {
      message: "Token Sent",
      sent_to: @authentication.login_handler,
    }, status: :ok
  end

  def authenticate_token
    return throw_401("Invalid token #{params[:token].inspect} for login_handler: #{params[:login_handler].inspect}") unless @authentication.authenticate(params[:token])
    return render(json: user_response(@authentication.users.first), status: :ok) if @authentication.users.size == 1

    if params[:user_id]
      user = @authentication.users.find_by(id: params[:user_id])
      return throw_400("Invalid user_id #{params[:user_id]} for login_handler: #{params[:login_handler].inspect}") unless user
      return render(json: user_response(user), status: :ok)
    end

    response = {
      message: 'Multiple users found. Need to also pass user_id parameter.',
      users: @authentication.users.includes(:organization).map { |user| user_list_response(user) }
    }

    render json: response, status: 409
  end

  def multi_account_login
    user = User.find params[:user_id]

    render json: user_response(user), status: :ok
  end

  private

  def user_response(user)
    {
      message: 'User Signed In',
      authentication_token: user.authentication_token,
      user_id: user.id,
      user_type: user.type,
      organization_id: user.organization_id
    }
  end

  def user_list_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      type: user.type,
      organization: {
        id: user.organization.id,
        name: user.organization.name,
        logo_url: user.organization.logo.expiring_url(expiring_url_time_in_seconds)
      }
    }
  end

  def hack_to_make_mobile_work
    params[:login_handler] = params[:login_handler].presence || params[:phone].presence || params[:email].presence
  end

  def find_authentication
    return throw_400('Missing parameter login_handler') if params[:login_handler].blank?

    @authentication = Authentication.for(params[:login_handler])

    throw_404('Phone/Email not found') if @authentication.blank?
  end
end
