class Api::V1::PaymentMethodsController < ApiController

  def create
    @patient = return_user_from_auth_token
    @token = request_token
    if @token.present? and @patient.present?
      if add_token_to_user(@token)
        api_return('Payment Method Added','200')
      end
    else
      api_return('Something went wrong, please check info and try again.','404')
    end
  end

  def index
    @patient = return_user_from_auth_token
  end

  private
  def payment_method_params
    params.permit(:number, :exp_m, :exp_y, :cvv)
  end

  def request_token
    if @patient
      Stripe::Token.create(
        :card => {
          :number => params[:number],
          :exp_month => params[:exp_m],
          :exp_year => params[:exp_y],
          :cvc => params[:cvv]
        },
      ) rescue nil
    end
  end

  def add_token_to_user(token)
    @patient.update_payment_method(@token) ? true : false
  end

end