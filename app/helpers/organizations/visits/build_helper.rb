module Organizations::Visits::BuildHelper
  def medication_duration_options
    [["Less than a month", "Less than a month"], ["More than a Month", "More than a Month"], ["More than 90 days", "More than 90 days"], ["More than a year", "More than a year"], ["More than 3 years","More than 3 years"]]
  end
end
