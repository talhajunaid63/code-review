require 'test_helper'

class AvailableTime::AsIntervalsService < ActiveSupport::TestCase
  
  setup do
    @available_time = available_times(:available_time_6)
    @date = DateTime.now.to_date

    @intervals = AvailableTimes::AsIntervalsService.new(@available_time, @date).perform
  end

  teardown do
    Delorean.back_to_the_present
  end

  test "generates 6 intervals from an available time" do
    assert_equal 6, @intervals.size
  end

  test "intervals are correctly instantited with Interval class" do
    assert @intervals.all? {|interval| interval.instance_of? Interval }
  end

  test "correctly pass available time instance to intervals" do
    assert @intervals.all? {|interval| interval.available_time.id == @available_time.id }
  end

  test "correctly pass date to intervals" do
    assert @intervals.all? {|interval| interval.date == @date }
  end  

  test "TokBox Service does not set recording if organization recording is not enabled" do
    
  end
end
