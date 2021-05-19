class Api::V1::CoordinatorsController < ApiController
  before_action :authorize_app, :auth_user
  before_action :ensure_org_admin, only: [:create]
  before_action :set_coordinator, only: [:show, :update]

  def show
  end

  def create
    result = ::Organizations::Coordinators::CreateService.new(coordinator_params).perform
    @coordinator = result.resource
    if result.success?
      api_resource_return("Coordinator created", @coordinator, 200)
    else
      api_errors_return(
        "Something went wrong.",
        @coordinator.errors.messages,
        400
      )
    end
  end

  def update
    if @coordinator.update(coordinator_params)
      api_resource_return("Coordinator updated", @coordinator, 200)
    else
      api_errors_return(
        "Something went wrong.",
        @coordinator.errors.messages,
        400
      )
    end
  end

  private

  def set_coordinator
    @coordinator = Coordinator.find(params[:id])
  end

  def coordinator_params
    attrs = params.require(:coordinator).permit(
      :avatar,
      :first_name,
      :last_name,
      :phone,
      :email,
      :source,
      :zip,
      :status,
      :coordinator_detail_attributes => [
        :role,
        :zip,
        :coordinator_id,
        :specialties
      ],
    )
    attrs[:organization_id] = @user.organization_id if params[:action] == "create"
    attrs
  end

end
