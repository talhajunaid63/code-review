class ApplicationPolicy
  attr_reader :user, :record, :organization

  def initialize(user, record)
    @user = user.user
    raise Pundit::NotAuthorizedError, "invalid_session" if @user.blank?

    @record = record
    @organization = user.organization
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  private

  def org_admin_privilege?
    user.org_admin? ||
      user.administrator? ||
      (user.provider? && user.provider_detail&.acts_as_org_admin) ||
      (user.coordinator? && user.coordinator_detail&.acts_as_org_admin)
  end

  def authenticate_org_admin
    return true if user.administrator?

    organization_member? && org_admin_privilege?
  end

  def organization_member?
    user.organization_id.present? && user.organization_id == organization&.id
  end

  def ensure_search_permission
    return true if user.administrator?
    return false unless user.organization_access?(organization)

    user.org_admin? || user.coordinator? || user.provider?
  end

  def ensure_visit_permissions
    return true if user.administrator?
    return false unless record.organization_access?(user.organization)

    user.org_admin? ||
      user.patient? && record.patient_access?(user) ||
      user.provider? && record.provider_access?(user) ||
      user.coordinator? && record.coordinator_access?(user)
  end

  def ensure_admin_or_org_membership
    return true if user.administrator?

    organization.blank? || user.organization_id == organization.id
  end

  def ensure_permissions
    return true unless user.patient?
    return false if record.is_a?(Enumerable)
    return user.id == record.id if record&.patient?
    return user.id == record.patient_id if record&.is_a?(Visit)

    true
  end

  def ensure_admin_or_ownership
    return true if user.administrator?
    return false if user.patient?

    if user.coordinator? && !user.coordinator_detail.acts_as_org_admin
      return false unless record&.is_a?(Coordinator)
      return false unless user.id == record.id
    end

    if user.provider? && !user.provider_detail.acts_as_org_admin
      return false unless record&.is_a?(Provider)
      return false unless user.id == record.id
    end

    if user.org_admin? ||
       (user.provider? && user.provider_detail.acts_as_org_admin) ||
       (user.coordinator? && user.coordinator_detail.acts_as_org_admin)
      if organization
        return false unless user.organization_id == organization.id
      end
    end

    true
  end

  def authenticate_org_admin_or_self
    return true if user.administrator? || record.blank? || user.self?(record)

    authenticate_org_admin
  end

  def authenticate_org_admin_or_coordinator
    user.administrator? ||
      user.org_admin? ||
      user.coordinator? ||
      user.provider? && org_admin_privilege?
  end

  def authenticate_org_admin_or_coordinator_or_provider
    user.administrator? || user.org_admin? || user.coordinator? || user.provider?
  end

  def authenticate_administrator
    user.administrator?
  end
end
