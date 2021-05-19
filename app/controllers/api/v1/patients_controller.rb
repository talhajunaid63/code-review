class Api::V1::PatientsController < ApiController
  before_action :authorize_app, :auth_user
  before_action :ensure_org_admin, only: [:create]
  before_action :set_patient, only: [:show, :update]
  before_action(only: [:show, :update]) { |c| c.ensure_org_admin_or_ownership(@patient) }

  def index
    @patients = @user.patients
  end

  def show
  end

  def create
    result = ::Organizations::Patients::CreateService.new(patient_params).perform
    @patient = result.resource
    if result.success?
      api_resource_return("Patient created", @patient, 200)
    else
      api_errors_return(
        "Something went wrong.",
        @patient.errors.messages,
        400
      )
    end
  end

  def update
    if @patient.update(patient_params)
      api_resource_return("Patient Updated", @patient, 200)
    else
      api_errors_return(
        "Something went wrong, please check your request.",
        @patient.errors.messages,
        400
      )
    end
  end

  private

  def set_patient
    @patient = Patient.find(params[:id])
  end

  def patient_params
    attrs = params.require(:patient).permit(
      :id,
      :email,
      :phone,
      :first_name,
      :last_name,
      :date_of_birth,
      :source,
      :zip,
      :basic_detail_attributes => [
        :dob_m,
        :dob_d,
        :dob_y,
        :gender,
        :address,
        :patient_id,
        :conditions,
        :client_unique_id,
      ],
      :insurance_detail_attributes => [
        :provider,
        :group_id,
        :no_insurance,
        :member_id,
        :patient_id
      ]
    )
    attrs[:organization_id] = @user.organization_id if params[:action] == "create"
    attrs = formatted_date_of_brith(attrs)
    attrs
  end

  def formatted_date_of_brith(attrs)
    basic_detail_params = attrs[:basic_detail_attributes]
    date_of_birth_keys = %w[dob_d dob_m dob_y]

    return attrs if basic_detail_params.blank? || !date_of_birth_keys.all? { |key| basic_detail_params.key?(key) }

    dob_m = basic_detail_params.delete(:dob_m)
    dob_d = basic_detail_params.delete(:dob_d)
    dob_y = basic_detail_params.delete(:dob_y)

    attrs[:date_of_birth] = Utils.format_date_of_birth(dob_m, dob_d, dob_y)
    attrs
  end
end
