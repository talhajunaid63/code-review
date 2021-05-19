class Organization < ApplicationRecord
  MAX_PATIENT_SEARCH_RESULTS = 20
  CONNECT_BUCKET_FILE = 'connect_bucket.txt'.freeze

  has_paper_trail ignore: %i[updated_at]

  attr_accessor :primary_state_id
  include ServiceAreaStates

  extend FriendlyId
  friendly_id :name, use: :sequentially_slugged
  after_initialize :set_defaults

  DEMO_NAME = 'DEMO_ORG_'
  DEMO_ZIP = '98001'

  TIERS = {
    individual: 'individual',
    practice: 'practice',
    professional: 'professional',
    integrated: 'integrated',
    free_full_access: 'free_full_access'
  }.freeze

  enum tier: TIERS

  before_save :ensure_api_token

  scope :paid_tier, -> { where(tier: [TIERS[:professional], TIERS[:practice]]) }

  has_one :organization_stat, dependent: :destroy
  belongs_to :creator, class_name: 'OrgAdmin'

  has_many :users, dependent: :destroy
  has_many :visits, class_name: '::Visit', dependent: :destroy
  has_many :visit_settings, dependent: :destroy
  has_many :metadata_settings, dependent: :destroy
  has_many :available_times, -> { distinct }, through: :users, dependent: :destroy
  has_many :reminder_settings, dependent: :destroy
  has_one :email_reminder_setting, dependent: :destroy
  has_one :sms_reminder_setting, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :payouts, dependent: :destroy
  has_many :visit_recordings, dependent: :destroy
  has_many :organization_states, dependent: :destroy
  has_many :states, through: :organization_states
  has_many :user_imports, dependent: :destroy

  validates :name, presence: true
  has_attached_file :logo, default_url: "https://uvohealth.s3-us-west-1.amazonaws.com/default_logo.png", :s3_protocol => :https
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  has_attached_file :hero, styles: { large: "1800>", medium: "300>" }, default_url: "https://uvohealth-marketing-aws.s3-us-west-1.amazonaws.com/default-org.png", :s3_protocol => :https
  validates_attachment_content_type :hero, content_type: /\Aimage\/.*\Z/

  has_attached_file :left_footer_image, s3_protocol: :https
  validates_attachment_content_type :left_footer_image, content_type: /\Aimage\/.*\Z/

  has_attached_file :right_footer_image, s3_protocol: :https
  validates_attachment_content_type :right_footer_image, content_type: /\Aimage\/.*\Z/

  validate :valid_zip_code
  validates_uniqueness_of :slug
  validates :slug, slug_format: true

  scope :demo_orgs, -> { where('name LIKE :name AND zip = :zip AND enable_chat = :enable_chat', { name: "#{DEMO_NAME}%", zip: DEMO_ZIP, enable_chat: true }) }
  COORDINATOR = 'coordinator'.freeze
  PATIENT = 'patient'.freeze
  PROVIDER = 'provider'.freeze

  def all_associations_versions
    Version.for_items(self.id, self.class.name)
      .or(Version.for_items(metadata_settings.ids, metadata_settings.name))
      .or(Version.for_items(visit_settings.ids, visit_settings.name))
      .or(Version.for_items(reminder_settings.ids, class_name(reminder_settings)))
      .or(Version.for_items(email_reminder_setting&.id, class_name(email_reminder_setting)))
      .or(Version.for_items(sms_reminder_setting&.id, class_name(sms_reminder_setting)))
      .or(Version.for_items(available_times.ids, available_times.name))
      .or(Version.for_items(organization_states.ids, organization_states.name))
      .includes(:created_by)
      .order(created_at: :desc)
  end

  def class_name(association)
    association.class.name.split('::').last
  end

  def providers
    users.not_archived.where(:type => "Provider")
  end

  def org_admins
    users.not_archived.where(:type => "OrgAdmin")
  end

  def data_settings
    if metadata_settings.present?
      metadata_settings.first
    else
      default_metadata_settings
    end
  end

  def set_defaults
    # Change default color #d0d0d0 to #B9E7F0
    self.brand_color ||= "#B9E7F0"
  end

  def display_brand_color
    if brand_color.nil? || brand_color.empty?
      "#2996cc"
    else
      brand_color
    end
  end

  def offset_brand_color
    chroma = Chroma.paint(display_brand_color)
    if chroma.dark?
      "#fafafa"
    else
      "#424242"
    end
  end

  def payment_required?
    return false unless visit_settings.present?
    if visit_settings.first.require_payment
      true
    else
      false
    end
  end

  def providers_available_times
    @available_times ||= available_times.by_providers(providers.ids)
  end

  def default_metadata_settings
    MetadataSetting.new(organization_id: id)
  end

  def default_visit_settings
    VisitSetting.new
  end

  def create_patient(login_handler)
    Patient.with_organization(self).create(login_handler: login_handler)
  end


  def patients
    Patient.with_organization(self).not_archived.includes(:basic_detail)
  end

  def coordinators
    Coordinator.with_organization(self).not_archived
  end

  def visit_setting
    visit_settings.last
  end

  def visit_rate
    return default_visit_settings.visit_rate unless visit_setting
    visit_setting.visit_rate
  end

  def visit_length
    visit_setting = visit_settings.blank? ? default_visit_settings : visit_settings.last

    visit_setting&.visit_length
  end

  def self_service_enabled?
    return false unless visit_setting
    visit_setting.self_service_enabled
  end

  def payment_required?
    return false unless visit_setting
    visit_setting.require_payment
  end

  def auth_number_required?
    return false unless visit_setting
    visit_setting.auth_number_required
  end

  def schedule_preference
    return "pooled" unless visit_setting
    if visit_setting.schedule_preference == "pooled"
      "pooled"
    else
      "individually_scheduled"
    end
  end

  def schedule_select
    return no_availability unless providers_available_times.present?

    intervals = AvailableTimes::Intervals::FindService.new(providers_available_times).perform
    intervals = intervals.map do |interval|
      base_datetime = interval.base_datetime
      display = base_datetime.strftime("%a, %B #{base_datetime.day.ordinalize}, %-l:%M %P") + " - #{interval.provider.time_zone} - #{distance_of_time_in_words(base_datetime.utc, DateTime.now.utc)} from now"
      [display.to_s, base_datetime.to_s]
    end
    intervals.uniq!
    intervals.sort_by{|x,y|y}
  end

  def schedule_select_with_provider
    return no_availability unless providers_available_times.present?

    intervals = AvailableTimes::Intervals::FindService.new(providers_available_times).perform
    intervals = intervals.map do |interval|
      base_datetime = interval.base_datetime
      display = base_datetime.strftime("%a, %B #{base_datetime.day.ordinalize}, %-l:%M %P") + " - #{interval.provider.name} - #{interval.provider.time_zone}"
      [display.to_s, [base_datetime.to_s, interval.provider.id]]
    end
    intervals.uniq!
    intervals.sort_by{|x,y|y}
  end

  def has_availability?
    available_times.exists?
  end

  def no_availability
    [['No Available Times - Please add times in providers', '']]
  end

  def visits_created_with_in(start_date, end_date)
    visits
      .includes(:incident_information, :medications, :conditions, :visit_detail, :user_visit_consents, :consent_users, :attendances, :video_logs, patient: :basic_detail)
      .where("visits.created_at >= :start_date AND visits.created_at <= :end_date", { start_date: start_date.beginning_of_day, end_date: end_date.end_of_day })
  end

  def has_payment?
    self.stripe_id.present?
  end

  def card_info
    if self.stripe_id
      @card_info = {}
      stripe_customer = Stripe::Customer.retrieve(self.stripe_id)
      stripe_card = stripe_customer.sources.retrieve(stripe_customer.default_source)
      @card_info[:brand] = stripe_card.brand
      @card_info[:exp_month] = stripe_card.exp_month
      @card_info[:exp_year] = stripe_card.exp_year.to_s.last(2)
      @card_info[:last4] = stripe_card.last4
      @card_info
    end
  end

  def update_stripe(card_token)
    if self.stripe_id
      update_stripe_account(card_token)
    else
      self.create_stripe_account(card_token)
    end
  rescue Stripe::CardError => e
    body = e.json_body
    body[:error]
    false
  end

  def update_stripe_account(card_token)
    stripe_customer = Stripe::Customer.retrieve(self.stripe_id)
    stripe_card = stripe_customer.sources.create({:source => card_token})
    new_default_id = stripe_card[:id]
    stripe_customer.default_source = new_default_id
    stripe_customer.description = "Organization(#{id}) slug: #{slug}"
    stripe_customer.metadata = { 'uvohealth_organization_id': self.id }
    stripe_customer.save
    true
  end

  def create_stripe_account(card_token)
    stripe_customer = Stripe::Customer.create(
      stripe_customer_data.merge(source: card_token)
    )
    self.stripe_id = stripe_customer.id
    self.save!
    true
  end

  def stripe_customer_data
    customer_data = {}
    customer_data[:description] = "Organization(#{id}) slug: #{slug}"
    customer_data[:metadata] = { 'uvohealth_organization_id': id }
    customer_data
  end

  def paid_users
    users.not_archived.where(type: ["Provider", "Coordinator", "OrgAdmin"])
  end

  def has_payout_method?
    self.payout_stripe_id.present?
  end

  def payout_method_info
    info = {}
    stripe_linked_account = Identity.where(provider: "stripe_connect", organization_id: self.id).first
    if stripe_linked_account
      info[:email] = stripe_linked_account.email
      info[:business_name] = stripe_linked_account.name
    end
    info
  end

  def ensure_api_token
    if api_token.blank?
      self.api_token = generate_api_token
    end
  end

  def set_primary_state_from_zip_code
    self.organization_states.update_all(is_primary: false) # when organization update
    state_from_zip = ZipCode.identify("#{self.zip}")
    return false unless state_from_zip
    state = State.find_by("code= ?", state_from_zip[:state_code])
    return false unless state
    org_state = self.organization_states.find_or_create_by(state: state)
    org_state.update(is_primary: true)
    self.providers.each do |provider|
      provider.provider_states.find_or_create_by(state: state)
    end
  end

  def service_area_states
    organization_states
  end

  def regenerate_api_token!
    update(api_token: generate_api_token)
  end

  def setting_mandatory?(field)
    visit_setting && visit_setting.public_send(field)
  end

  def can?(action)
    Permission.new(tier, action).permitted?
  end

  def subscription
    subscriptions.first
  end

  def on_paid_plan?
    professional? || practice?
  end

  def left_footer_section_blank?
    left_footer_image.blank? && left_footer_title.blank? && left_footer_description.blank?
  end

  def right_footer_section_blank?
    right_footer_image.blank? && right_footer_title.blank? && right_footer_description.blank?
  end

  def current_plan
    return Organization::Plan.unscoped.find_by(name: Organization::Plan::SPECIAL_PLAN_NAME) if free_full_access?

    Organization::Plan.find_by(name: tier)
  end

  def current_plan?(plan)
    current_plan == plan
  end

  def updated_features(new_plan)
    features = []
    lost_features = current_plan.features - new_plan.features
    gained_features = new_plan.features - current_plan.features

    lost_features.each { |feature| features.push({ name: feature.name, new: false }) }
    gained_features.each { |feature| features.push({ name: feature.name, new: true }) }

    features
  end

  def waiting_content?
    visit_setting && (visit_setting.waiting_video.present? || visit_setting.waiting_image.present?)
  end

  def org_admin
    org_admins.first
  end

  def collects_reference_number?
    return false if metadata_settings.blank?

    metadata_settings.last.reference_number
  end

  def paid_subscription?
    practice? || professional?
  end

  def self.demo
    Organization
      .demo_orgs
      .free_full_access
      .first_or_create(name: "#{DEMO_NAME}#{SecureRandom.alphanumeric}", zip: DEMO_ZIP, enable_chat: true)
  end

  def bucket_connected?
    bucket_name.present?
  end

  private

  def generate_api_token
    loop do
      token = Devise.friendly_token
      break token unless Organization.where(api_token: token).first
    end
  end

  def valid_zip_code
    state = ZipCode.identify("#{self.zip}")
    unless state
      errors.add(:zip,"Code is Invalid")
    end
  end

end
