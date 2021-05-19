module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where('archived_at IS NOT NULL') }
    scope :not_archived, -> { where('archived_at IS NULL') }
  end

  def archived?
    archived_at != nil
  end

  def archive!
    self.update_attributes(archived_at: Time.now.utc)
  end

  def unarchive!
    self.update_attributes(archived_at: nil)
  end
end
