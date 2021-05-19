require 'test_helper'

class AvailableTime::IntervalsFindServiceTest < ActiveSupport::TestCase
  include TextMessageHelper

  setup do
    @provider = providers(:provider_antoine)

     # We travel to next week Wednesday
     Delorean.time_travel_to Date.today.next_week.advance(:days=>2)

    @intervals = AvailableTimes::Intervals::FindService.new(
      @provider.available_times, DateTime.now.to_date, days=3
    ).perform
    stubs_text_message_send_text
  end

  teardown do
    Delorean.back_to_the_present
  end

  test "finds 12 intervals from provider available times" do
    assert_equal 12, @intervals.size
  end

  test "finds 6 intervals for Wednesday from 8pm to 9:40pm" do
    day, intervals = @intervals.group_by(&:date).map(&:itself).first
    assert_equal 3, day.wday
    assert_equal 6, intervals.size
    assert_equal "8:00 pm", intervals.first.base_datetime.strftime("%-I:%M %P")
    assert_equal "8:10 pm", intervals.second.base_datetime.strftime("%-I:%M %P")
    assert_equal "8:50 pm", intervals.last.base_datetime.strftime("%-I:%M %P")
  end

  test "finds 6 intervals for Saturday from 4pm to 5:40pm" do
    day, intervals = @intervals.group_by(&:date).map(&:itself).last
    assert_equal 6, day.wday
    assert_equal 6, intervals.size
    assert_equal "4:00 pm", intervals.first.base_datetime.strftime("%-I:%M %P")
    assert_equal "4:50 pm", intervals.last.base_datetime.strftime("%-I:%M %P")
  end
end
