class OrgSetups::PlanSelectionsController < ApplicationController
  before_action :set_org_setup

  def new
    @plan_selection_form = OrgSetup::PlanSelection.new(org_setup_id: @org_setup.id)
    @plans = Organization::Plan.order(:display_order)
    @features = Organization::Feature.order(:created_at)
  end

  def create
    @plan_selection_form = OrgSetup::PlanSelection.new(plan_selection_params)
    if @plan_selection_form.process
      redirect_to OrganizationOnboardingService.new(@org_setup).next_step
    else
      flash.now[:alert] = @plan_selection_form.errors.full_messages.first
      render :new
    end
  end

  private

  def plan_selection_params
    params.require(:org_setup_plan_selection).permit(:plan_id, :org_setup_id)
  end

  def set_org_setup
    @org_setup = OrgSetup.find(params[:org_setup_id])
  end
end
