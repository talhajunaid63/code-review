module UsersHelper

  def user_edit_link(user)
    case user.type
    when "Provider"
      Rails.application.routes.url_helpers.edit_organization_provider_path(user.organization, user)
    when "Patient"
      Rails.application.routes.url_helpers.edit_organization_patient_path(user.organization, user)
    when "Coordinator"
      Rails.application.routes.url_helpers.edit_organization_coordinator_path(user.organization, user)
    end
  end
end
