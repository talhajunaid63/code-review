class OrgSetups::BasicDetailsController < ApplicationController
  before_action :set_org_setup

  def new
    @basic_detail_form = OrgSetup::BasicDetail.new(org_setup_id: @org_setup.id)
  end

  def create
    @basic_detail_form = OrgSetup::BasicDetail.new(basic_detail_params)
    if @basic_detail_form.process
      redirect_to next_step
    else
      flash.now[:alert] = @basic_detail_form.errors.full_messages.first
      render :new
    end
  end

  private

  def basic_detail_params
    params.require(:org_setup_basic_detail).permit(
      :name,
      :description,
      :zip,
      :phone,
      :slug,
      :org_setup_id
    )
  end

  def set_org_setup
    @org_setup = OrgSetup.find(params[:org_setup_id])
  end

  def next_step
    return onboarding_service.next_step if @org_setup.can?(onboarding_service.current_step_key)

    onboarding_service.next_to_current_step
  end

  def onboarding_service
    @onboarding_service ||= OrganizationOnboardingService.new(@org_setup)
  end
end
