class Api::V1::Visits::ConditionsController < ApiController
  before_action :authorize_app, :auth_user
  before_action :set_visit

  def index
    @conditions = @visit.conditions
  end

  def create
    return invalid_request unless params[:conditions].present?
    params[:conditions].each do |condition|
      @visit.conditions.create(condition_params(condition))
    end
    api_return("Conditions added to visit", '200')
  end

  private

  def condition_params(params)
    attrs = params.permit(
      :name
    )
    attrs[:patient_id] = @visit.patient.id
    attrs
  end

  def set_visit
    @visit = Visit.find(params[:visit_id])
  end

  def invalid_request
    api_return(
      "Invalid Request. Conditions are required.",
      400,
    )
  end

end
