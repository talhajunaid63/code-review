class StripeUsageRecordService < ApplicationService
  TYPE = 'users'.freeze

  attr_accessor :organization, :type, :recording_duration

  def initialize(organization, type = TYPE, recording_duration = 0)
    @organization = organization
    @type = type
    @recording_duration = recording_duration
  end

  def perform
    Stripe::SubscriptionItem.create_usage_record(
      subscription_item_id,
      {
        quantity: quantity,
        timestamp: Time.zone.now.to_i,
        action: 'set',
      }
    )

    organization.organization_stat.update(paid_users_count: paid_users_count) if type == TYPE

    Result.new(organization, true, 'Latest quantity is successfully updated.')
  rescue Stripe::StripeError => e
    Result.new(organization, false, e.message)
  end

  private

  def quantity
    return paid_users_count if type == TYPE

    recording_duration
  end

  def subscription_item_id
    return organization.subscription.stripe_subscription_item_id if type == TYPE

    organization.subscription.stripe_recording_subscription_item_id
  end

  def paid_users_count
    @paid_users_count ||= organization.paid_users.count
  end
end
