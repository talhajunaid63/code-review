class Action < ApplicationRecord
  EVENTS = %i{
    login
    login_successful
    logout
    one_click_login_attempt
    visit_show
    right_now_visit_create
    session_timeout
    session_invalid
    content_restricted
    consent_show
    consent_given
    not_authorized
    setup_new_wi_visit
    patient_zip_create
    patient_dob_create
    patient_time_zone_create
    patient_basics_create
    visit_medical_details_create
    visit_case_details_create
    visit_incident_information_create
    visit_schedule_create
    visit_scheduled_notification
  }.inject({}) { |_, v| _[v] = v.to_s ; _}.freeze

  enum event: EVENTS

  serialize :metadata, JSON

  belongs_to :user
  belongs_to :actionable, polymorphic: true

  validates :event, presence: true

  def self.log(event, user = nil, actionable = nil, metadata = nil, browser = nil, request = nil)
    user_id = user.is_a?(User) && user.id || user

    options = {
      event: event,
      user_id: user_id,
      metadata: metadata,
    }

    options.merge!(
      os_name: browser.platform.name,
      os_version: browser.platform.version,
      browser_name: browser.name,
      browser_version: browser.full_version
    ) if browser

    options.merge!(
      ip_address: request.remote_ip,
      referrer: request.referrer
    ) if request

    options.merge!(actionable_type: actionable.class.name, actionable_id: actionable.id) if actionable

    create! options
  end
end
