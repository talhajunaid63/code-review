require 'test_helper'

class IntervalTest < ActiveSupport::TestCase

  setup do
    # This available time block is 20:00 to 22:OO
    # from provider Antoine Ward
    # with time zone "Central Time (US & Canada)"
    @available_time = available_times(:available_time_6)
    @date = DateTime.now.to_date
  end

  test 'interval base datetime is set in provider time zone' do
    interval = Interval.new(@available_time, @date, 0)
    assert_equal "Central Time (US & Canada)", interval.base_datetime.time_zone.name
    assert_equal "8:00 pm", interval.base_datetime.strftime("%-I:%M %P")
  end

  test 'interval class correctly set times based on interval index' do
    # This works because the intervals selected in visit_settins are set to 10 minutes.

    times = [
      "8:00 pm", "8:10 pm", "8:20 pm", "8:30 pm", "8:40 pm", "8:50 pm",
      "9:00 pm", "9:10 pm", "9:20 pm", "9:30 pm", "9:40 pm", "9:50 pm"
    ]

    6.times do |i|
      assert_equal times[i], Interval.new(@available_time, @date, i).base_datetime.strftime("%-I:%M %P")
    end
  end

  test 'correctly return time in Pacific Time (US & Canada)' do
    interval = Interval.new(@available_time, @date, 0)
    assert_equal "Pacific Time (US & Canada)", interval.datetime_in("Pacific Time (US & Canada)").time_zone.name
    assert_equal "6:00 pm", interval.datetime_in("Pacific Time (US & Canada)").strftime("%-I:%M %P")
  end

  test 'correctly return time in Central Time (US & Canada)' do
    interval = Interval.new(@available_time, @date, 0)
    assert_equal "Central Time (US & Canada)", interval.datetime_in("Central Time (US & Canada)").time_zone.name
    assert_equal "8:00 pm", interval.datetime_in("Central Time (US & Canada)").strftime("%-I:%M %P")
  end

  test 'correctly return time in Eastern Time (US & Canada)' do
    interval = Interval.new(@available_time, @date, 0)
    assert_equal "Eastern Time (US & Canada)", interval.datetime_in("Eastern Time (US & Canada)").time_zone.name
    assert_equal "9:00 pm", interval.datetime_in("Eastern Time (US & Canada)").strftime("%-I:%M %P")
  end

end
