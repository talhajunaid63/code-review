class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def stripe_connect
    omniauth = request.env["omniauth.auth"]
    identity = Identity.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    organization = Organization.find(session[:organization_id])

    omniauth["organization_id"] = organization.id

    current_user.add_identity(omniauth)

    organization.payout_stripe_id = omniauth.dig(:extra, :raw_info, :stripe_user_id)
    organization.save

    session[:organization_id] = nil

    redirect_to organization_payouts_path(
      organization
    ), notice: "Withdrawal Method Added!"
  end

end
