class Users::UnarchivePolicy < ApplicationPolicy
  def destroy?
    authenticate_org_admin
  end
end
