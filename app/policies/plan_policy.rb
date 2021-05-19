class PlanPolicy < ApplicationPolicy
  def submit_request?
    return authenticate_org_admin if organization.present?

    true
  end
end
