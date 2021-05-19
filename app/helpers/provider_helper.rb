module ProviderHelper
  def provider_availability_badge(provider)
    return no_avialability if provider.no_avialability?
    available_times_badge(provider)
  end

  def no_avialability
    %(<i class='uvoi-calendar' aria-hidden='true'></i>
        &nbsp;No Availability).html_safe
  end

  def available_times_badge(provider)
    %(<i class='uvoi-calendar' aria-hidden='true'></i>
      &nbsp;#{pluralize(provider.available_times.count,'Available Time')}).html_safe
  end

  def provider_role_types
    [
      "Medical Doctor",
      "Nurse Practitioner",
      "Physician Assistant",
      "Registered Nurse",
      "Pharmacist",
      "Pharmacy Technician",
      "Therapist",
      "Provider",
    ]
  end

  def primary_state(organization)
    organization.primary_state&.state_name || 'Unknown'
  end

  def non_primary_state(organization)
    organization.organization_states.non_primary.state_asc
  end

  def provider_states(provider)
    states_id = []
    provider.provider_states.each do |pro_state|
      states_id << pro_state.state_id
    end
    states_id
  end

  def organization_state_name(organization)
    organization.organization_states.state_asc.map{ |obj| [obj.state_name,obj.state_id] }
  end
end
