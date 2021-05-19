class OrganizationState < ApplicationRecord
  has_paper_trail ignore: %i[updated_at]

  belongs_to :organization
  belongs_to :state
  delegate :name,:id, to: :state, prefix: :state

  scope :is_primary, -> { where(is_primary: true) }
  scope :non_primary, -> { where(is_primary: false) }
  scope :state_asc, -> { includes(:state).order('states.name asc') }

  def is_primary?
    self.is_primary
  end
end
