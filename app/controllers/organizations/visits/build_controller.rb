class Organizations::Visits::BuildController < ApplicationController
  include Wicked::Wizard


  steps :case_details,:incident_information, :medical_details, :schedule, :confirm


  before_action :authenticate_user
  before_action :set_org
  before_action :find_visit, only: [:show, :update, :finish_wizard_path, :create_incident_info]
  before_action :ensure_and_set_patient, only: [:show]
  before_action :ensure_self_service, only: %i[show]
  before_action :set_total_steps

  def show
    authorize @visit, policy_class: Organizations::VisitPolicy

    @meds_required = @patient.organization.data_settings.medications?
    @conditions_required = @patient.organization.data_settings.conditions?

    @patient.ensure_insurance_detail
    @patient.ensure_basic_detail

    @visit.medications.build if @visit.medications.blank?
    @visit.conditions.build if @visit.conditions.blank?

    @available_times = AvailableTime.all
    case step
    when :medical_details
      skip_step if !@patient.organization.data_settings.conditions && !@patient.organization.data_settings.medications
      log_action Action::EVENTS[:visit_medical_details_create], current_user, @visit, {url: request.path}
    when :case_details
      skip_step unless @patient.organization.data_settings.visit_notes
      log_action Action::EVENTS[:visit_case_details_create], current_user, @visit, {url: request.path}
    when :incident_information
      @incident_info = IncidentInformation.new
      skip_step if !@patient.organization.data_settings.incident_information || @visit&.patient&.basic_detail&.client_unique_id.blank?
      log_action Action::EVENTS[:visit_incident_information_create], current_user, @visit, {url: request.path}
    when :schedule
      log_action Action::EVENTS[:visit_schedule_create], current_user, @visit, {url: request.path}
      if @visit&.patient&.basic_detail&.client_unique_id.present? && !current_user.consented?(@visit)
        @visit.active!
        return redirect_to organization_visit_path(@visit.organization, @visit.id)
      end

      @intervals = AvailableTimes::Intervals::FindService.new(@patient.organization.providers_available_times).perform
      @intervals_available_now = AvailableTimes::Intervals::AvailableNowService.new(@intervals).perform
    end

    render_wizard
  end

  def update
    @visit.update_attributes(visit_params.except(:provider_ids))
    @visit.add_providers(visit_params[:provider_ids]) if @visit.errors.blank? && visit_params[:provider_ids].present?
    render_wizard @visit
  end

  def create
    @visit = Visit.create
    redirect_to wizard_path(:visit_id => @visit.id)
  end

  def create_incident_info
    @incident_info = @visit.create_incident_information(incident_params)
    render_wizard @visit
  end

  def finish_wizard_path
    dashboard_organization_patient_path(current_user.organization, current_user)
  end

  private

  def visit_params
    params.require(:visit).permit(
      :patient_id,
      :organization_id,
      :dependent_id,
      :schedule,
      :status,
      :patient_notes,
      :provider_notes,
      :start_date_time,
      :end_date_time,
      :state,
      provider_ids: [],
      medications_attributes: [:id, :name, :how_long, :_destroy],
      conditions_attributes: [:id, :name, :_destroy]
    )
  end

  def incident_params
    params.require(:incident_information).permit(:incident_description, :activity_performed, :patient_id, :date_y, :date_m, :date_d,)
  end

  def set_total_steps
    organization_steps = steps
    if current_user.basic_detail&.client_unique_id.present?
      organization_steps = organization_steps.reject {|s| s == :case_details }
      organization_steps = organization_steps.reject {|s| s == :confirm }
    else
      unless current_user.organization.data_settings.conditions || current_user.organization.data_settings.medications
        organization_steps = organization_steps.reject {|s| s == :medical_details }
      end
      organization_steps = organization_steps.reject {|s| s == :case_details } unless current_user.organization.data_settings.visit_notes
      if current_user.organization.data_settings.incident_information && @visit&.patient&.basic_detail&.client_unique_id.present?
        organization_steps = organization_steps.reject {|s| s == :case_details }
      else
        organization_steps = organization_steps.reject {|s| s == :incident_information }
      end
    end
    @total_steps = organization_steps.count
    @current_step = params[:current_step].present? ? params[:current_step].to_i : organization_steps.index(@step).to_i
  end

  def set_org
    @organization = Organization.friendly.find(params[:organization_id])
  end

  def find_visit
    @visit = Visit.find(params[:visit_id])
  end

  def ensure_self_service
    return if @patient.basic_detail&.client_unique_id.present?

    not_authorized unless @organization.self_service_enabled?
  end
end
