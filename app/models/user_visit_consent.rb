class UserVisitConsent < ApplicationRecord
  has_paper_trail ignore: %i[updated_at]

  belongs_to :user
  belongs_to :visit

  validates :user_id, uniqueness: { scope: :visit_id }
end
