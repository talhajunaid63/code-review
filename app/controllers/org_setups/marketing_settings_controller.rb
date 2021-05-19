class OrgSetups::MarketingSettingsController < ApplicationController
  before_action :set_org_setup
  before_action :set_organization

  include PermissionConcern

  def new
    @marketing_settings_form = OrgSetup::MarketingSetting.new(org_setup_id: @org_setup.id)
    authorize @marketing_settings_form, policy_class: OrgSetups::MarketingSettingPolicy
  end

  def create
    @marketing_settings_form = OrgSetup::MarketingSetting.new(marketing_setting_params)
    authorize @marketing_settings_form, policy_class: OrgSetups::MarketingSettingPolicy

    if @marketing_settings_form.process
      redirect_to org_setup_marketing_setting_path(@org_setup, 1)
    else
      flash.now[:alert] = @marketing_settings_form.errors.full_messages.first
      render :new
    end
  end

  def show
    @next_step = OrganizationOnboardingService.new(@org_setup).next_step
    @organization = @org_setup.organization
    authorize @organization, policy_class: OrgSetups::MarketingSettingPolicy
  end

  private

  def marketing_setting_params
    params
    .require(:org_setup_marketing_setting)
    .permit(
      :logo, :hero, :brand_color, :org_setup_id, :left_footer_image, :left_footer_title,
      :left_footer_description, :right_footer_image, :right_footer_title, :right_footer_description
    )
  end

  def set_org_setup
    @org_setup = OrgSetup.find(params[:org_setup_id])
  end

  def set_organization
    @organization = @org_setup.organization
  end

  def permify_params
    { object: @org_setup, action: Permission::MARKETING }
  end
end
