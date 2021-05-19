class Api::V1::ApiPingsController < ApiController
  before_action :authorize_app, except: [:ping]

  def ping
    render json: {
      message: 'All Systems Go!',
      }, status: 200
  end

  def ping_token
    render json: {
      message: "SUCCESS!",
      }, status: 200
  end

end
