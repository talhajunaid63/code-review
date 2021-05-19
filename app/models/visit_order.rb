# Form object to allow coordinators and org administrators to create visits
class VisitOrder
  include ActiveModel::Model

  delegate :organization, to: :visit

  attr_accessor(
    :patient_id,
    :organization_id,
    :notes,
    :medications,
    :conditions,
    :schedule,
    :schedule_end,
    :auth_number,
    :provider_ids,
    :coordinator_ids,
    :client_unique_id,
    :type
  )

  attr_reader :visit

  # validates :patient_id, presence: true
  validates :organization_id, presence: true
  validates :schedule, presence: true

  def build_visit
    return false unless valid?
    @visit = Visit.new(
      patient_id: patient_id,
      organization_id: organization_id,
      patient_notes: notes,
      schedule: schedule,
      schedule_end: schedule_end,
      auth_number: auth_number,
      client_unique_id: client_unique_id,
      type: type
    )
    build_visit_providers
    build_visit_coordinators
    visit.save
  end

  def build_visit_providers
    provider_ids.to_a.reject(&:blank?).each do |provider_id|
      visit.visit_providers.find_or_initialize_by(provider_id: provider_id)
    end
  end

  def build_visit_coordinators
    coordinator_ids.to_a.reject(&:blank?).each do |coordinator_id|
      visit.visit_coordinators.find_or_initialize_by(coordinator_id: coordinator_id)
    end
  end

  def visit
    @visit
  end
end
