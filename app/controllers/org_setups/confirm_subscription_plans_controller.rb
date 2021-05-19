class OrgSetups::ConfirmSubscriptionPlansController < ApplicationController
  before_action :set_org_setup

  def new
    set_organization_and_plan
    @confirm_subscription_plan_form = OrgSetup::ConfirmSubscriptionPlan.new(org_setup_id: @org_setup.id)
  end

  def create
    @confirm_subscription_plan_form = OrgSetup::ConfirmSubscriptionPlan.new(org_subscription_plan_params)
    if @confirm_subscription_plan_form.process
      redirect_to OrganizationOnboardingService.new(@org_setup).next_step
    else
      set_organization_and_plan
      flash.now[:alert] = @confirm_subscription_plan_form.errors.full_messages.first
      render :new
    end
  end

  private

  def org_subscription_plan_params
    params.require(:org_setup_confirm_subscription_plan).permit(:org_setup_id)
  end

  def set_org_setup
    @org_setup = OrgSetup.find(params[:org_setup_id])
  end

  def set_organization_and_plan
    @plan = Organization::Plan.find(@org_setup.plan_id)
    @organization = Organization.find(@org_setup.organization_id)
  end
end
