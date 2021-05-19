class User < ApplicationRecord
  has_paper_trail ignore: %i[last_activity_at updated_at]

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  VALID_PHONE_NUMBER_REGEX = /\A(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\z/
  PER_PAGE = 18
  MAX_PER_PAGE = 100
  SEARCHABLE_AGAINST = %i[first_name last_name phone email zip]
  SESSION_ACTIVE_THRESHOLD = 2.hours
  EXPORT_LIMIT = 1000

  include ActionView::Helpers::TextHelper
  acts_as_token_authenticatable
  include Archivable
  include Searchable

  validates :login_handler, presence: true

  validates :phone, format: { with: VALID_PHONE_NUMBER_REGEX }, numericality: { only_integer: true }, if: :phone?
  validates :email, format: { with: VALID_EMAIL_REGEX }, if: :email?

  before_save :normalize_email
  before_validation :clean_phone_number

  belongs_to :organization

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :lastseenable, :omniauthable, :omniauth_providers => [:stripe_connect]

  has_one :payment_method, :dependent => :destroy
  has_one :insurance_detail, :dependent => :destroy
  has_one :online_user, dependent: :destroy

  accepts_nested_attributes_for :payment_method, :update_only => true
  accepts_nested_attributes_for :insurance_detail, :update_only => true

  has_many :identities, dependent: :destroy
  has_many :actions, dependent: :destroy
  has_many :available_times, :dependent => :destroy
  has_many :user_visit_consents, dependent: :destroy
  has_many :consent_visits, through: :user_visit_consents, source: :visit
  has_many :attendances, class_name: 'VisitAttendance', dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :reference_number, uniqueness: { scope: [:organization_id, :type] }, if: -> { reference_number.present? }

  has_attached_file :avatar,
                    styles: { large: "600x600#", medium: "300x300#", thumb: "100x100#" },
                    default_url: "https://uvohealth-marketing-aws.s3-us-west-1.amazonaws.com/default-user.png",
                    :s3_protocol => :https
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  scope :with_organization, -> (organization) { where(organization_id: organization.id) }
  scope :present_visit_attendances, -> (visit_id) { joins(:attendances).where(visit_attendances: { visit_id: visit_id, attending: true }) }

  CATEGORIES = {
    regular: 'regular',
    demo: 'demo'
  }

  enum category: CATEGORIES

  def active!
    update(last_activity_at: Time.zone.now)
  end

  def idle?
    return false if last_activity_at.blank?

    (Time.zone.now - last_activity_at).round(2) >= SESSION_ACTIVE_THRESHOLD
  end

  def all_associations_versions
    Version.for_items(self.id, 'User')
      .or(Version.for_items(available_times.ids, available_times.name))
      .or(Version.for_items(user_visit_consents.ids, user_visit_consents.name))
      .includes(:created_by)
      .order(created_at: :desc)
  end

  def self.normalize_login_handler(login_handler)
    return normalize_email(login_handler) if login_handler =~ VALID_EMAIL_REGEX
    return normalize_phone(login_handler) if login_handler =~ VALID_PHONE_NUMBER_REGEX
  end

  def self.normalize_email(email)
    email.to_s.downcase.gsub(/\s+/, '')
  end

  def self.normalize_phone(phone_number)
    clean_number = phone_number.delete("^0-9")
    clean_number = clean_number.last(10) if clean_number.length > 10 && clean_number.first == '1'
    clean_number
  end

  def self.for(login_handler)
    scope = not_archived
    return scope.where(email: normalize_email(login_handler)) if login_handler =~ VALID_EMAIL_REGEX
    return scope.where(phone: normalize_phone(login_handler)) if login_handler =~ VALID_PHONE_NUMBER_REGEX
    where("1=0")
  end

  def notifications_enabled!
    update(notifications_enabled: true)
  end

  def name
    [first_name, last_name].compact.join(" ").strip.presence
  end

  def time_zone
    return self[:time_zone] if self[:time_zone].present?
    self[:time_zone] = time_zone_from_zip_code(self[:zip])
  end

  def email_required?
    false
  end

  def online?
    if last_seen
      last_seen > 20.minutes.ago
    else
      false
    end
  end

  def last_seen_pst
    if last_seen
      Time.parse("#{self.last_seen} UTC").in_time_zone("Pacific Time (US & Canada)").strftime('%I:%M %p')
    else
      'Unknown'
    end
  end

  def last_seen_ago
    if last_seen
      @days = (DateTime.now - Date.parse(last_seen.to_s)).to_i
      pluralize(@days, "Day Ago", "Days Ago")
    else
      "Unknown"
    end
  end

  def update_payment_method(card_token)
    if stripe_id.blank?
      new_stripe_account(card_token)
    else
      update_stripe(card_token)
    end
  end

  def new_stripe_account(card_token)
    customer = Stripe::Customer.create(
      source: card_token,
      email: email,
      phone: phone,
      description: stripe_description
    )
    self.stripe_id = customer.id
    payment_to_database(customer)
    save!
  end

  def stripe_description
    description = "#{type}(#{id}) "
    description += "email: #{email} " if email.present?
    description += "phone: #{phone} " if phone.present?

    description
  end

  def add_identity(omniauth)
    identity = self.identities.new(
      provider: omniauth['provider'],
      uid: omniauth['uid'],
      token: omniauth.dig(:credentials, :token),
      refresh_token: omniauth.dig(:credentials, :refresh_token),
      expires: omniauth.dig(:credentials, :expires),
      expires_at: omniauth.dig(:credentials, :expires_at),
    )
    identity.organization_id = omniauth["organization_id"] if omniauth.key?("organization_id")
    identity.email = omniauth.dig(:extra, :extra_info, :email)
    identity.name = omniauth.dig(:extra, :extra_info, :business_name) if identity.provider == "stripe_connect"
    identity.save
  end

  def update_stripe(card_token)
    customer = Stripe::Customer.retrieve(stripe_id)
    old_card_id = customer.sources.first.id
    customer.sources.create(source: card_token)
    customer.sources.retrieve(old_card_id).delete
    customer = Stripe::Customer.retrieve(stripe_id)
    payment_to_database(customer)
    save!
  end

  # save the new card information to the database
  def payment_to_database(customer)
    if self.payment_method.blank?
      self.build_payment_method
    end
    self.payment_method.stripe_card_id = customer[:sources][:data].last[:id]
    self.payment_method.last_4 = customer[:sources][:data].last[:last4]
    self.payment_method.brand = customer[:sources][:data].last[:brand]
    self.payment_method.exp_m = customer[:sources][:data].last[:exp_month]
    self.payment_method.exp_y = customer[:sources][:data].last[:exp_year]
  end

  def has_payment?
    #TODO remove this test method - This makes it so this specific test user always has a payment.
    if self.phone == '5558885555'
      true
    elsif self.stripe_id
      true
    else
      false
    end
  end

  def claimed?
    if self.step == 3
      true
    else
      false
    end
  end

  def phone?
    phone.present?
  end

  def email?
    email.present?
  end

  def login_handler
    phone.presence || email.presence
  end

  def login_handler=(login_handler)
    return if login_handler.blank?

    if VALID_PHONE_NUMBER_REGEX =~ login_handler
      self.phone = login_handler
    else
      self.email = login_handler
    end
  end

  def phone=(new_phone)
    self[:phone] = self.class.normalize_phone new_phone
  end

  def email=(new_email)
    self[:email] = self.class.normalize_email new_email
  end

  def consented?(visit)
    consent_visits.unscope(where: :category).include? visit
  end

  def patient?
    is_a?(Patient)
  end

  def coordinator?
    is_a?(Coordinator)
  end

  def provider?
    is_a?(Provider)
  end

  def org_admin?
    is_a?(OrgAdmin)
  end

  def administrator?
    is_a?(Administrator)
  end

  def dropdown_display_name
    name
  end

  def ensure_payment_method
    payment_method || build_payment_method
  end


  def organization_access?(org)
    organization_id == org.id
  end

  def online_for
    online_user.presence || build_online_user
  end

  def online?
    online_for.online?
  end

  def mark_online!
    online_for.update_attributes online: true
  end

  def mark_offline!
    online_for.update_attributes online: false
  end

  def self?(user)
    self.id == user.id
  end

  private

  def normalize_email
    if self.email
      self.email = self.class.email(self.email)
    end
  end

  def time_zone_from_zip_code(zip)
    response = ZipCode.identify("#{zip}")
    ActiveSupport::TimeZone::MAPPING.key(response[:time_zone]) if response.present?
  end

  def clean_phone_number
    if self.phone.present?
      self.phone = self.class.phone_number(self.phone)
    end
  end

  def self.email(email)
    email.to_s.downcase.strip
  end

  def self.phone_number(phone_number)
    clean_number = phone_number.delete("^0-9")
    clean_number = clean_number.last(10) if clean_number.length > 10 && clean_number.first == '1'
    clean_number
  end
end
