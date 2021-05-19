class ExportUsersService
  attr_reader :q, :type, :organization_id

  def initialize(q:, type:, organization:)
    @q = q
    @type = type
    @organization = organization
  end

  def process
    users = method("search_#{type}").call
    CSV.generate(headers: true) do |csv|
      csv << headers.push(type)

      users.each do |user|
        csv << method("data_for_#{type}").call(user).push(true)
      end
    end
  end

  private

  def search_patient
    FindPatientsQuery
      .new(@organization.patients)
      .call(query: q)
      .includes(:basic_detail)
      .limit(User::EXPORT_LIMIT)
  end

  def search_provider
    FindProvidersQuery
      .new(@organization.providers)
      .call(query: q)
      .includes(:provider_detail)
      .limit(User::EXPORT_LIMIT)
  end

  def search_coordinator
    FindCoordinatorsQuery
      .new(@organization.coordinators)
      .call(query: q)
      .includes(:coordinator_detail)
      .limit(User::EXPORT_LIMIT)
  end

  def headers
    common_headers + (type == 'patient' ? patient_headers : coordinator_and_provider_headers)
  end

  def common_headers
    %w[id first_name last_name phone email time_zone reference_number]
  end

  def coordinator_and_provider_headers
    %w[acts_as_org_admin]
  end

  def patient_headers
    %w[gender date_of_birth address city state zip_code]
  end

  def common_fields(user)
    [
      user.id,
      user.first_name,
      user.last_name,
      user.phone,
      user.email,
      user.time_zone,
      user.reference_number
    ]
  end

  def data_for_patient(patient)
    basic_detail = patient.ensure_basic_detail
    common_fields(patient) + [basic_detail.gender_text, patient.date_of_birth, basic_detail.address, basic_detail.city, basic_detail.state, patient.zip]
  end

  def data_for_coordinator(coordinator)
    common_fields(coordinator) + [coordinator.coordinator_detail&.acts_as_org_admin]
  end

  def data_for_provider(provider)
    common_fields(provider) + [provider.provider_detail&.acts_as_org_admin]
  end
end
