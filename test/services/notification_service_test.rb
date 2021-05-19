require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include TextMessageHelper

  setup do
    @visit = visits(:visit_24)
    @provider = providers(:provider_janet)
    stubs_text_message_send_text
  end

  def send_notification
    Visits::RightNow::NotificationsService.new(@visit, false).perform
  end

  test 'sends notification if provider is available.' do
    current_time = Time.find_zone(@provider.time_zone).now
    available_time = @provider.available_times.create(day: current_time.wday, time_block: 1)

    Delorean.time_travel_to current_time.change(hour: available_time.time_block + 2)
    previous_notification_count = @provider.notifications_count
    send_notification
    @provider.reload
    assert_equal previous_notification_count + 1 , @provider.notifications_count
    Delorean.back_to_the_present
  end

  test 'if provider is not available' do
    previous_notification_count = @provider.notifications_count
    send_notification
    @provider.reload
    assert_equal previous_notification_count, @provider.notifications_count
  end
end
