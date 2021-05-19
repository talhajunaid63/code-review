class UserImport < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  has_many :import_failures, class_name: 'UserImportFailure', dependent: :delete_all

  scope :for_type, ->(type) { where(import_type: type) }
  scope :for_organization, ->(organization) { where(organization: organization) }
  scope :pending_or_running, -> { where('status = ? OR status = ?', STATUSES[:pending], STATUSES[:running]) }

  validate :import_type_validation

  ALLOWED_TYPES = [Organization::COORDINATOR, Organization::PATIENT, Organization::PROVIDER].freeze

  STATUSES = {
    pending: 'pending',
    running: 'running',
    stopped: 'stopped',
    completed: 'completed',
    failed: 'failed',
  }.freeze

  enum status: STATUSES

  def processed?
    stopped? || completed? || failed?
  end

  def failures_csv
    CSV.generate do |csv|
      csv << [headers, 'reason'].flatten
      import_failures.includes(:user_import).each do |failure|
        csv << failure.to_csv_row
      end
    end
  end

  def import_type_validation
    errors.add(:import_type, 'is incorrect') unless ALLOWED_TYPES.include?(import_type)
  end
end
