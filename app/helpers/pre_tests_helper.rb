module PreTestsHelper
  def pre_test_status_icon(patient)
    {
      'success' => 'fa-check text-success',
      'failed' => 'fa-times text-danger',
      'pending' => 'fa-paper-plane-o text-warning'
    }[patient.pre_test&.category_status]
  end

  def pre_test_status_colour(patient)
    {
      'success' => 'text-success',
      'failed' => 'text-danger',
      'pending' => 'text-warning'
    }[patient.pre_test&.category_status]
  end

  def format_date(date, format='%m/%d/%Y %H:%M %p')
    return '-' if date.blank?

    Time.at(date).strftime(format)
  end

  def initiator_name_and_link(user)
    return '-' if user.blank?

    link_to user.name || 'N/A', [:edit, @organization, user]
  end
end
