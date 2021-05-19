require "test_helper"
class ProviderAvailableTimesControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper

  setup do
    @organization = organizations(:uvo_health)
    @patient = patients(:patient_44)
  end

  test "Index - returns availability individually/by provider properly" do
    get v1_organization_provider_available_times_path(@organization.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    first_interval = AvailableTimes::Intervals::FindService.new(@organization.providers_available_times).perform.first
    first_interval_time_text = first_interval.date.strftime("%A, %B #{first_interval.date.day.ordinalize}")
    assert response_json.to_s.include? "Janet Whitehouse"
    assert response_json.to_s.include? first_interval_time_text
  end

end
