# frozen_string_literal: true

module Organizations::FacetsHelper
  def total_visits(organization, visits)
    total_entries_tag do
      visits.count
    end
  end

  def total_providers(organization, providers = nil)
    total_entries_tag do
      providers&.total_count || organization.providers.count
    end
  end

  def total_patients(organization, patients = nil)
    total_entries_tag do
      patients&.total_count || organization.patients.count
    end
  end

  def total_coordinators(organization, coordinators = nil)
    total_entries_tag do
      coordinators&.total_count || organization.coordinators.count
    end
  end

  def total_org_admins(organization, org_admins = nil)
    total_entries_tag do
      org_admins&.total_count || organization.org_admins.count
    end
  end

  def total_entries_tag
    content_tag(:span, "(#{yield})", class: 'entries-count')
  end
end
