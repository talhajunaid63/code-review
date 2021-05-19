class Organization::ReminderSetting < ApplicationRecord
  extend ReminderSettingsHelper
  has_paper_trail ignore: %i[updated_at]

  belongs_to :organization

  enum send_via: { email: 1, sms: 2 }

  validates :patient_send_at, :provider_send_at, inclusion: { in: reminders_send_at_array.map(&:last),
                                                 message: "%{value} is not valid",
                                                 allow_blank: true,
                                                 allow_nil: true }


end
