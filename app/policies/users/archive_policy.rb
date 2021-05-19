class Users::ArchivePolicy < ApplicationPolicy
  def create?
    authenticate_org_admin
  end
end
