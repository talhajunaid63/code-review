require 'test_helper'

class StripeCardServiceTest < ActiveSupport::TestCase
  include OpenTokHelper

  setup do
    @patient = patients(:patient_1)
  end

  test 'Stripe card service creates payment method' do
    StripeMock.start
      response = stripe_card('9191', 2024)
    StripeMock.stop

    assert_equal true, response.success?
    assert_equal true, @patient.payment_method.present?
    assert_equal 9191, @patient.payment_method.last_4
  end

  test 'Stripe card service updates payment method' do
    StripeMock.start
      stripe_card('9191', 2024)
      update_response = stripe_card('4242', 2023)
    StripeMock.stop

    assert_equal true, update_response.success?
    assert_equal true, @patient.payment_method.present?
    assert_equal 4242, @patient.payment_method.last_4
  end

  private

  def stripe_card(last4, exp_year)
    card_token = StripeMock.generate_card_token(last4: last4, exp_year: exp_year)
    StripeCardService.new(@patient, card_token).process
  end
end
