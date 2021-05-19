class PagePolicy < ApplicationPolicy
  def system?
    authenticate_administrator
  end
end
