class VisitSetting < ApplicationRecord
  has_paper_trail ignore: %i[updated_at]

  belongs_to :organization, optional: false

  enum schedule_preference: { pooled: 1, individually_scheduled: 2 }

  has_attached_file :waiting_image, s3_protocol: :https
  validates_attachment_content_type :waiting_image, content_type: /\Aimage\/.*\Z/

  has_attached_file :waiting_video, s3_protocol: :https
  validates_attachment_content_type :waiting_video, content_type: /\Avideo\/.*\Z/
end
