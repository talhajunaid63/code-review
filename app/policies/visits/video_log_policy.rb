class Visits::VideoLogPolicy < ApplicationPolicy
  def show?
    ensure_visit_permissions
  end

  def create?
    ensure_visit_permissions
  end
end
