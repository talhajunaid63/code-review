class VisitPolicy < ApplicationPolicy
  def demo?
    ensure_permissions
  end

  def invite?
    user.provider? && record.provider_access?(user) || user.coordinator? && record.coordinator_access?(user)
  end
end
