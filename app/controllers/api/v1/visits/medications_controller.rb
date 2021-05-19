class Api::V1::Visits::MedicationsController < ApiController
  before_action :authorize_app, :auth_user
  before_action :set_visit

  def index
    @medications = @visit.medications
  end

  def create
    return invalid_request unless params[:medications].present?
    params[:medications].each do |medication|
      @visit.medications.create(medication_params(medication))
    end
    api_return("Medications added to visit", '200')
  end

  private

  def medication_params(params)
    attrs = params.permit(
      :name, :how_long
    )
    attrs[:patient_id] = @visit.patient.id
    attrs
  end

  def set_visit
    @visit = Visit.find(params[:visit_id])
  end

  def invalid_request
    api_return(
      "Invalid Request. Medications are required.",
      400,
    )
  end

end
