class StripeEvents::AccountDeauthorizedService
  def call(event)
    stripe_account_id = event.account rescue nil
    return unless stripe_account_id

    organization = Organization.find_by_payout_stripe_id(stripe_account_id)

    if organization
      Identity.where(provider: "stripe_connect", organization_id: organization.id).destroy_all
      organization.payout_stripe_id = nil
      organization.save
    end
  end
end
