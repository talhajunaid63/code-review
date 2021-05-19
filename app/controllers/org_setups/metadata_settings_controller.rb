class OrgSetups::MetadataSettingsController < ApplicationController
  before_action :set_org_setup
  before_action :set_organization

  def new
    @metadata_settings_form = OrgSetup::MetadataSettingForm.new(org_setup_id: @org_setup.id)
    authorize @metadata_settings_form, policy_class: OrgSetups::MetadataSettingPolicy
  end

  def create
    @metadata_settings_form = OrgSetup::MetadataSettingForm.new(metadata_setting_params)
    authorize @metadata_settings_form, policy_class: OrgSetups::MetadataSettingPolicy

    if @metadata_settings_form.process
      redirect_to OrganizationOnboardingService.new(@org_setup).next_step
    else
      flash.now[:alert] = @metadata_settings_form.errors.full_messages.first
      render :new
    end
  end

  private

  def metadata_setting_params
    attrs =
      params.require(:org_setup_metadata_setting_form).permit(
        :org_setup_id,
        :address,
        :medications,
        :conditions,
        :visit_notes,
        :dob,
        :gender,
        :reference_number
      )

    if @org_setup.can?(Permission::SYSTEM_INTEGRATION)
      attrs.merge!(incident_information: params[:org_setup_metadata_setting_form][:incident_information])
    end

    attrs
  end

  def set_org_setup
    @org_setup = OrgSetup.find(params[:org_setup_id])
  end

  def set_organization
    @organization = @org_setup.organization
  end
end
