class OrgSetups::VisitSettingsController < ApplicationController
  before_action :set_org_setup
  before_action :set_organization

  def new
    @visit_settings_form = OrgSetup::VisitSettingForm.new(org_setup_id: @org_setup.id)
    authorize @visit_settings_form, policy_class: OrgSetups::VisitSettingPolicy
  end

  def create
    @visit_settings_form = OrgSetup::VisitSettingForm.new(visit_setting_params)
    authorize @visit_settings_form, policy_class: OrgSetups::VisitSettingPolicy

    if @visit_settings_form.process
      redirect_to OrganizationOnboardingService.new(@org_setup).next_step
    else
      flash.now[:alert] = @visit_settings_form.errors.full_messages.first
      render :new
    end
  end

  private

  def visit_setting_params
    attrs =
      params.require(:org_setup_visit_setting_form).permit(
        :org_setup_id,
        :visit_length,
        :visit_buffer,
        :require_payment,
        :schedule_preference,
        :self_service_enabled,
        :mandatory_diagnoses,
        :mandatory_patient_history,
        :mandatory_patient_status,
        :mandatory_plan,
        :waiting_image,
        :waiting_video
      )

    attrs.merge!(visit_rate: params[:org_setup_visit_setting_form][:visit_rate]) if @org_setup.can?(Permission::MARKETING)
    attrs
  end

  def set_org_setup
    @org_setup = OrgSetup.find(params[:org_setup_id])
  end

  def set_organization
    @organization = @org_setup.organization
  end
end
