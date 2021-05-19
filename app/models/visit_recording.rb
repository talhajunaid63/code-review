class VisitRecording < ApplicationRecord
  EXPIRY = 60.days
  PER_PAGE = 15
  RECORDING_PLAN_NAME = 'video recording'.freeze

  has_paper_trail ignore: %i[updated_at]

  belongs_to :organization, optional: false
  belongs_to :visit, optional: false

  scope :not_expired, -> { where("expired_at > ?", Time.now) }
  scope :expiring_next_week, -> {
    next_week = Time.now.next_week.beginning_of_day
    where(expired_at: next_week..next_week.end_of_week.end_of_day)
  }
  scope :created_within, -> (from, to) { where(created_at: from..to) }

  def size_in_gb
    size.to_f / 1024 / 1024 / 1024
  end

  def download_cost
    0.09 * size_in_gb
  end

  def storage_cost
    0.023 * size_in_gb * 2
  end

  def duration_in_minutes
    duration.to_f / 60
  end

  def recording_cost
    0.025 * duration_in_minutes
  end

  def call_cost
    0.00475 * duration_in_minutes
  end

  def cost
    download_cost + storage_cost + recording_cost + call_cost
  end

  def downloaded!
    update_attributes downloaded_at: Time.now
  end
end
