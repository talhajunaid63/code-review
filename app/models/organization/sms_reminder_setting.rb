class Organization::SmsReminderSetting < Organization::ReminderSetting
  has_paper_trail ignore: %i[updated_at]
  belongs_to :organization

  default_scope { where(send_via: 2) }
end
