class ExportPatientsCsvService

  def initialize(patients)
    @patients = patients
  end

  def process
    CSV.generate(headers: true) do |csv|
      csv << attributes

      @patients.each do |patient|
        csv << data_for(patient)
      end
    end
  end

  def attributes
    [
      'id',
      'created_date',
      'first_name',
      'last_name',
      'gender',
      'age',
      'phone',
      'email',
      'address',
      'city_state',
      'zip',
      'conditions',
      'last seen',
      'coordinator_id',
      'status',
      'source',
      'reference_number',
    ]
  end

  def data_for(patient)
    [
       patient.id,
       patient.created_at,
       patient.first_name,
       patient.last_name,
       patient.gender_text,
       patient.age,
       patient.phone,
       patient.email,
       patient.address,
       patient.city_state,
       patient.zip,
       patient.conditions,
       patient.last_seen,
       patient.coordinator&.id,
       patient.status,
       patient.source,
       patient.reference_number,
    ]
  end

end
