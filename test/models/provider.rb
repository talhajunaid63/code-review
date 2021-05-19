require 'test_helper'

class ProviderTest < ActiveSupport::TestCase
  setup do
    @provider = providers(:provider_janet)
    @visit = visits(:visit_8)
    @patient = patients(:patient_44)
  end

  test "Provider.visits only returns visits within that providers organization" do
    @provider.visits.count < Visit.all.count
  end

  test 'check provider availablity between 8am to 10am' do
    current_time = Time.zone.now
    @provider.available_times.create(time_block: 4, day: current_time.wday)

    Delorean.time_travel_to current_time.beginning_of_day.change(hour: 2)
    assert_not @provider.available?

    Delorean.time_travel_to current_time.beginning_of_day.change(hour: 8, min: 30)
    assert @provider.available?

    Delorean.time_travel_to current_time.beginning_of_day.change(hour: 12, min: 30)
    assert_not @provider.available?
  end
end
