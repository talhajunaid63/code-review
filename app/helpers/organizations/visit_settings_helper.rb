module Organizations::VisitSettingsHelper

  def vist_length_increment_list
    {
      "5 Minutes": 5,
      "10 Minutes": 10,
      "15 Minutes": 15,
      "20 Minutes": 20,
      "30 Minutes": 30,
      "45 Minutes": 45,
      "60 Minutes": 60
    }
  end

  def mandatory_options
    [['Mandatory', true], ['Optional', false]]
  end
end
