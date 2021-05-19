class Visit < ApplicationRecord
  self.inheritance_column = nil

  has_paper_trail ignore: %i[updated_at]

  include ActionView::Helpers::DateHelper

  require 'rest-client'
  require 'json'

  PER_PAGE = 18
  NEAR_TO_SCHEDULE_TIME = 30
  DASHBOARD_UPCOMING_DURATION = 30.minutes
  MAX_PARTICIPANTS = 6
  DEMO_VISIT_DURATION = 5.minutes

  serialize :online_users

  belongs_to :patient, optional: true
  belongs_to :organization, optional: true
  has_one :web_rtc_detail
  has_one :visit_detail, dependent: :destroy

  has_many :medications, :dependent => :destroy
  has_many :conditions, :dependent => :destroy
  has_many :visit_recordings, :dependent => :destroy
  has_many :user_visit_consents, dependent: :destroy
  has_many :consent_users, through: :user_visit_consents, source: :user
  has_many :video_logs, dependent: :destroy
  has_many :attendances, class_name: 'VisitAttendance', dependent: :destroy
  has_many :visit_providers, dependent: :destroy
  has_many :providers, through: :visit_providers
  has_many :visit_coordinators, dependent: :destroy
  has_many :coordinators, through: :visit_coordinators
  has_many :notifications, dependent: :destroy
  has_many :voip_call_logs, dependent: :destroy

  has_one :incident_information, :dependent => :destroy
  has_one :pre_test_detail, dependent: :destroy
  accepts_nested_attributes_for :web_rtc_detail
  accepts_nested_attributes_for :conditions, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :medications, allow_destroy: true, reject_if: :all_blank

  attr_accessor :request_auth_token,
                :peer_connection_data

  default_scope { where.not(category: [CATEGORIES[:pre_test], CATEGORIES[:demo]]) }

  scope :no_patient, -> { where(patient_id: nil) }
  scope :pending_for_payout, -> { where(status: 10) }
  scope :right_now_or_is_nill,  -> { where(status: [11, nil]) }
  scope :confirmed_right_now_or_is_nil, -> { right_now_or_is_nill.order(schedule: :asc).all_confirmed }
  scope :future, -> { where('schedule >= ?', Time.now.utc) }
  scope :upcoming, -> { active.future.or(right_now) }
  scope :by_coordinators, -> (coordinator_ids) { joins(:visit_coordinators).where(visit_coordinators: { coordinator_id: coordinator_ids }) }
  scope :by_providers, -> (provider_ids) { joins(:visit_providers).where(visit_providers: { provider_id: provider_ids }) }
  scope :by_scheduled_within, -> (window_in_minutes) { where("(schedule BETWEEN now() AND (now() + INTERVAL '? min')) AND (created_at NOT BETWEEN (schedule + INTERVAL '30 min') AND (schedule - INTERVAL '30 min'))", window_in_minutes) }
  scope :attending, -> { joins(:attendances).where("visit_attendances.attending = ? AND visit_attendances.updated_at > ?", true, VisitAttendance::TTL.ago) }
  scope :ordered_attending, -> { attending.order('visit_attendances.updated_at DESC') }
  scope :dashboard, -> { active.where("schedule > ?", DASHBOARD_UPCOMING_DURATION.ago.utc).order("patient_available_at ASC") }
  scope :with_coordinators_and_providers, -> { where.not('array_length(provider_ids, 1) is null OR array_length(coordinator_ids, 1) is null') }
  scope :created_within, -> (from, to) { where("visits.created_at >= :start_date AND visits.created_at <= :end_date", { start_date: from.beginning_of_day, end_date: to.end_of_day }) }
  scope :with_organization, -> (organization) { where(organization_id: organization.id) }

  CODECS = {
    vp8: 'VP8',
    h264: 'H264',
    no_codec: 'no_codec',
  }.freeze

  enum codec: CODECS

  STATES = {
    pending: 'pending',
    active: "active",
    cancelled: "cancelled",
    completed: "completed",
  }

  enum state: STATES

  TYPES = {
    scheduled: "scheduled",
    right_now: "right_now",
    workplace_incident: "workplace_incident"
  }

  enum type: TYPES

  CATEGORIES = {
    regular: 'regular',
    pre_test: 'pre_test',
    demo: 'demo'
  }

  enum category: CATEGORIES

  CATEGORY_STATUSES = {
    pending: 'pending',
    success: 'success',
    failed: 'failed'
  }

  enum category_status: CATEGORY_STATUSES, _suffix: true

  def all_associations_versions
    Version.for_items(self.id, self.class.name)
      .or(Version.for_items(medications.ids, medications.name))
      .or(Version.for_items(conditions.ids, conditions.name))
      .or(Version.for_items(incident_information&.id, incident_information.class.name))
      .or(Version.for_items(visit_recordings.ids, visit_recordings.name))
      .or(Version.for_items(user_visit_consents.ids, user_visit_consents.name))
      .includes(:created_by)
      .order(created_at: :desc)
  end


  def add_providers(provider_ids)
    provider_ids.reject(&:blank?).each do |provider_id|
      visit_providers.find_or_create_by(provider_id: provider_id)
    end
  end

  def add_coordinators(coordinator_ids)
    coordinator_ids.reject(&:blank?).each do |coordinator_id|
      visit_coordinators.find_or_create_by(coordinator_id: coordinator_id)
    end
  end

  def one_click_patient_login_visit_url(recipent = patient)
    [:email, :phone].map do |key|
      login_handler = recipent[key]
      next if login_handler.blank?

      authentication = Authentication.for(login_handler)
      if authentication.blank?
        Rails.logger.warn "Authentication for #{login_handler.inspect} not found"
        next
      end

      authentication.create_token skip_notifications: true
      Rails.application.routes.url_helpers.visit_short_url(self, i: authentication.id, c: authentication.token, u: recipent.id)
    end.compact.last
  end

  def providers_names
    providers.collect(&:name)
  end

  def coordinators_names
    coordinators.collect(&:name)
  end

  def patient_response_time
    return if patient_on_boarding_at.blank? || patient_sms_sent_at.blank?

    (patient_on_boarding_at - patient_sms_sent_at) / 60
  end

  def duration
    return if end_date_time.blank? || start_date_time.blank?

    Time.at(end_date_time - start_date_time).utc.strftime('%H:%M:%S')
  end

  def set_start_date!
    return if patient_id.blank? || providers.blank?

    self.update(start_date_time: Time.now)
  end

  def should_confirm_phone?
    patient&.phone.present? && !phone_confirmed
  end

  def coordinator_name
    coordinators&.map(&:name)&.join(' & ')
  end

  def ensure_visit_detail
    visit_detail || build_visit_detail
  end

  def consented_by
    user_visit_consents.includes(:user).collect(&:user).collect(&:name).flatten.compact.join(', ')
  end

  def notifications_scheduled!
    update(notifications_scheduled: true)
  end

  def self.all_confirmed
    active.where("schedule > ?", 1.day.ago.utc).where.not(patient_id: nil)
  end

  def self.all_in_the_past
    select do |record|
      record.in_the_past?
    end
  end

  def patient_waiting?
    patient_available_at.present? && attending?(patient)
  end

  def silence_reminders
    update_attributes(
      patient_email_reminder_queued_at: Time.now,
      provider_email_reminder_queued_at: Time.now,
      patient_sms_reminder_queued_at: Time.now,
      provider_sms_reminder_queued_at: Time.now
    )
  end

  def in_the_past?
    if self.schedule
      @one_year_ago = Time.parse(Time.now.strftime('%y/%m/%d %I:%M %p +0000')) - 1.years
      @visit_scheudle = self.schedule
      @one_day_ago = Time.parse(Time.now.strftime('%y/%m/%d %I:%M %p +0000')) - 1.days
      (@one_year_ago.. @one_day_ago).cover?(@visit_scheudle)
    end
  end

  def enterable?
    return false unless active?
    return true unless schedule

    schedule > 24.hours.ago
  end

  def self.all_completed
    select do |record|
      record.completed?
    end
  end

  def scheduled_time
    if self.schedule
      self.schedule.strftime("%A, %B #{self.schedule.utc.day.ordinalize} %l:%M %p %Z")
    else
      "Visit Not scheduled"
    end
  end

  def scheduled_time_for_user(user)
    return self.scheduled_time if user.time_zone.blank?
    schedule.in_time_zone("#{user.time_zone}").strftime("%A, %B #{schedule.in_time_zone("#{user.time_zone}").day.ordinalize} %l:%M %p %Z")
  end

  def time_started
    if self.start_date_time
      self.start_date_time.strftime("%A, %B #{self.start_date_time.day.ordinalize} %l:%M %p")
    else
      "No Start Time Entered"
    end
  end

  def ended?
    self.end_date_time ? true : false
  end

  def time_ended
    if self.end_date_time
      self.end_date_time.strftime("%A, %B #{self.end_date_time.day.ordinalize} %l:%M %p")
    else
      "No End Time Entered"
    end
  end

  def schedule_string
    if schedule
      @string = schedule.strftime("%A, %b %e at %-I:%M%P")
    else
      "Schedule Not Set"
    end
  end

  def in_days
    if schedule
      @time_in_days = distance_of_time_in_words(DateTime.now, schedule)
      "In " + @time_in_days
    else
      "Schedule Not Set"
    end
  end

  def confirmed?
    !self.completed?
  end

  def now?
    if self.schedule
      @block_start_time = self.schedule - 30.minutes
      @block_end_time = self.schedule + 30.minutes
      @current_time = DateTime.now
      (@block_start_time.. @block_end_time).cover?(@current_time)
    end
  end

  def instant?
    if self.schedule
      @block_start_time = self.schedule - 30.minutes
      @block_end_time = self.schedule + 30.minutes
      if self.created_at
        @created_at = DateTime.parse(self.created_at.strftime('%y/%m/%d %I:%M %p +0000'))
        (@block_start_time.. @block_end_time).cover?(@created_at)
      else
        false
      end
    end
  end

  def status_text
    case self.status
    when 1
      "Visit Created, Pending more information to confirm."
    when 2
      "Visit Created, Pending more information to confirm."
    when 3
      "Visit Created, Pending more information to confirm."
    when 4
      "Visit Created, Pending more information to confirm."
    when 5
      "Visit Created, Pending more information to confirm."
    when 6
      "Visit Confirmed"
    when 7
      "Visit Completed"
    when 8
      "Visit Canceled"
    when 9
      "Visit Completed and Not Yet Paid"
    when 10
      "Visit Completed and Paid"
    when 11
      "Right Now"
    else
      "Status Unknown"
    end
  end

  def self.all_complete_and_unpaid
    select do |record|
      record.complete_and_unpaid?
    end
  end

  def self.all_complete_and_paid
    select do |record|
      record.complete_and_paid?
    end
  end

  def complete_and_unpaid?
    self.status == 9 ? true : false
  end

  def complete_and_paid?
    self.status == 10 ? true : false
  end

  def patient_name
    patient&.name
  end

  def patient_phone
    patient&.phone
  end

  def visit_for
    return Dependent.find_by(id: self.dependent_id) if self.dependent_id.present?
    patient if patient_id.present?
  end

  def provider_online
    time_ago_in_words(DateTime.now - rand(0..1).minutes) + " ago"
  end

  def patient_online
     time_ago_in_words(DateTime.now - rand(5..90).minutes) + " ago"
  end

  def started
    !!self.start_date_time
  end

  def start_unix_time
    start_date_time.strftime("%s") if start_date_time
  end

  def ended
    !!self.end_date_time
  end

  def end_unix_time
    end_date_time.strftime("%s") if end_date_time
  end

  def scheduled_unix_time
    schedule.strftime("%s")
  end

  def overview_data
    {
      scheduled_start_time: self.scheduled_unix_time,
      started: self.started,
      start_time: self.start_unix_time,
      ended: self.ended,
      end_time: self.end_unix_time
    }
  end

  def schedule_date
    if schedule
      schedule.strftime("%D")
    end
  end

  def invoice_details
    if stripe_invoice
      Stripe::Invoice.retrieve(self.stripe_invoice)
    end
  end

  def invoice_total
    (self.invoice_details.total / 100).to_money.format
  end

  def notify_providers_via_sms!
    Provider.all.each do |provider|
      next if provider.phone.blank?

      scheudled_time = now? ? "NOW - INSTANT VISIT" : scheduled_time_for_user(provider)
      name = patient_name.presence || "Unknown"
      content = "UvoHealth -  Patient #{name} has just entered the waiting room, the visit is scheduled for #{@scheudled_time}."

      TextMessage.send_text(content, provider.phone)
    end
  end

  def process_payment
    return unless status == 7
    if organization.payment_required? && patient.has_payment?
      charge_patient!
    end
  end

  def update_open_tok_data
    TokBoxService.new(self).set_and_save_data
  end

  def no_medications?
    return false if self.medications.size.zero?
    self.medications.first.name == "None"
  end

  def no_conditions?
    return false if self.conditions.size.zero?
    self.conditions.first.name == "None"
  end

  def patient_access?(user)
    patient_id == user.id
  end

  def provider_access?(user)
    providers.blank? || providers.ids.include?(user.id)
  end

  def coordinator_access?(user)
    coordinators.blank? || coordinators.ids.include?(user.id)
  end

  def organization_access?(org)
    organization_id == org.id
  end

  def participants_count
    count = 0

    count += 1 if patient.present?
    count += providers.length + coordinators.length

    count
  end

  def attendance_for(user)
    self.attendances.where(user_id: user.id).first_or_initialize
  end

  def attending?(user)
    attendance = attendance_for(user)
    attendance.attending? && attendance.active?
  end

  def mark_present!(user, codecs = [])
    attendance_for(user).update_attributes(attending: true, codecs: codecs)
    self.update_attributes patient_available_at: Time.now if user.patient?
  end

  def refresh_attendance!(user)
    VisitAttendance.where(visit_id: self.id, user_id: user.id).update_all(updated_at: Time.now)
  end

  def mark_absent!(user)
    attendance_for(user).update_attributes(attending: false, codecs: [])
    self.update_attributes patient_available_at: nil if user.patient?
  end

  def absent_participants
    participants - User.present_visit_attendances(id)
  end

  def participant?(user)
    participants.include?(user)
  end

  def participants
    (providers + coordinators + [patient]).compact
  end

  def attending_count
    attendances.attending.count
  end

  def codec_postfix
    h264? ? CODECS[:h264] : CODECS[:vp8]
  end

  def non_patient_participants
    participants - [patient]
  end

  def near_to_schedule_time?(user)
    scheduled_time_difference(user) <= NEAR_TO_SCHEDULE_TIME
  end

  def near_to_schedule_time(user)
    scheduled_time_difference(user).minutes
  end

  def scheduled_time_difference(user)
    (schedule.in_time_zone(user.time_zone) - Time.zone.now.in_time_zone(user.time_zone)) / 60
  end

  def self.pre_tests_for(patient)
    unscope(where: :category).where(patient_id: patient.id).pre_test
  end

  def ensure_pre_test_detail
    pre_test_detail || build_pre_test_detail
  end

  def self.add_pre_test_for(patient, creator)
    pre_test = pre_tests_for(patient).pre_test_by(creator).pending_category_status.first_or_create
    pre_test.ensure_pre_test_detail.update(user_id: creator.id) if creator.coordinator? || creator.provider?
    pre_test.patient.update_pre_test_id!(pre_test.id)

    pre_test
  end

  def self.pre_test_by(creator)
    joins(:pre_test_detail).where(pre_test_details: { user_id: creator.id })
  end

  def pre_test_creator
    User.find_by(id: providers.first || coordinators&.first)
  end

  def pre_test_details_url
    Rails.application.routes.url_helpers.organization_patient_pre_test_url(organization, patient, self)
  end

  def self.demo_visit_for(provider)
    unscope(where: :category)
      .where(organization_id: Organization.demo.id)
      .by_providers(provider.id).demo.first_or_create do |demo_visit|
        demo_visit.provider_ids = [provider.id]
        demo_visit.schedule = Time.zone.now
      end
  end

  def destroy_demo_visit
    participants.map(&:destroy) && destroy
  end

  def voip_call_logs_time_range
    voip_call_logs.formatted_ringing_and_completed_time
  end
end
