class OrgSetups::OrgPaymentMethodsController < ApplicationController
  before_action :set_org_setup, :set_organization, :hide_navigation

  def new
    @payment_method_form = Organization::PaymentMethod.new(organization_id: @organization.id)
  end

  def create
    @payment_method_form = Organization::PaymentMethod.new(
      organization_id: @organization.id, stripe_token: params[:payment_method][:stripe_card_id]
    )
    if @payment_method_form.process
      @org_setup.update_column(:step, 10)
      redirect_to OrganizationOnboardingService.new(@org_setup).next_step
    else
      flash.now[:alert] = @payment_method_form.errors.full_messages.first
      render :new
    end
  end

  private

  def set_org_setup
    @org_setup = OrgSetup.find(params[:org_setup_id])
  end

  def set_organization
    @organization = @org_setup.organization
  end

  def hide_navigation
    @hide_nav = true
  end
end
