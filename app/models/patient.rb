class Patient < User
  has_many :visits, dependent: :destroy
  has_many :visit_details, dependent: :destroy
  has_many :dependents, :dependent => :destroy
  has_many :medications, :dependent => :destroy
  has_many :conditions, :dependent => :destroy

  has_one :basic_detail, :dependent => :destroy

  belongs_to :coordinator

  validate :valid_zip_code

  accepts_nested_attributes_for :basic_detail, :update_only => true

  before_validation :zip_to_city_state

  before_destroy :destroy_visits

  def valid_zip_code
    errors.add(:zip, :invalid) if zip.present? && ZipCode.identify(zip.to_s).blank?
  end

  def coordinator_name
    coordinator&.name
  end

  def address
    basic_detail&.address
  end

  def name_with_time_zone
    "#{name} - #{time_zone}"
  end

  def pre_test
    Visit.unscoped.find_by(id: ensure_basic_detail.pre_test_id)
  end

  def update_pre_test_id!(pre_test_id)
    ensure_basic_detail.update(pre_test_id: pre_test_id)
  end

  def dropdown_display_name
    display_name = []
    if name.present?
      display_name << name
      display_name << "[#{date_of_birth}]" if date_of_birth.present?
    end
    display_name << Utils.format_phone(phone) if phone.present?
    display_name << "<#{email}>" if email.present?
    display_name.join(" ")
  end

  def age
    return if date_of_birth.blank?

    birth_year = date_of_birth.split('/').last.to_i
    Date.today.year - birth_year
  end

  def has_insurance?
    if self.insurance_detail
      if self.insurance_detail.provider != nil
        true
      end
    end
  end

  def dob_m
    date_of_birth.to_s.split('/')[0]
  end

  def dob_d
    date_of_birth.to_s.split('/')[1]
  end

  def dob_y
    date_of_birth.to_s.split('/')[2]
  end

  def gender
    basic_detail ? basic_detail.gender : nil
  end

  def gender_text
    basic_detail ? basic_detail.gender_text : nil
  end

  def employer_email
    basic_detail ? basic_detail.employer_email : nil
  end

  def route
    return "/organizations/#{self.organization.slug}/patients/#{self.id}/build/zip" if self.zip.blank?
    return "/organizations/#{self.organization.slug}/patients/#{self.id}/build/dob" if self.date_of_birth.blank?
    return "/organizations/#{self.organization.slug}/patients/#{self.id}/build/basics" if self.name.blank?
    "/organizations/#{self.organization.slug}/patients/#{self.id}/dashboard"
  end

  def has_payment?
    self.payment_method&.stripe_card_id.present?
  end

  def payment_required?
    organization&.visit_setting&.require_payment.present?
  end

  def medical_summary
    @details = {}
    @details[:medications] =  self.medications.map { |medication| [medication.name,medication.how_long] }.to_h
    @details[:conditions] = self.conditions
    @details
  end

  def city_state
    return "Unknown Location" unless basic_detail
    return "Unknown Location" unless basic_detail.city && basic_detail.state
    "#{basic_detail.city}, #{basic_detail.state}"
  end

  def ensure_basic_detail
    basic_detail || build_basic_detail
  end

  def ensure_insurance_detail
    insurance_detail || build_insurance_detail
  end

  private

  def destroy_visits
    self.visits.each do |visit|
      visit.destroy!
    end
  end

  def zip_to_city_state
    return false unless basic_detail
    return false unless zip
    zip_data = ZipCode.identify("#{zip}")
    if zip_data
      basic_detail.city = zip_data[:city]
      basic_detail.state = zip_data[:state_code]
    else
      false
    end
  end
end
