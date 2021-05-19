class Organizations::Patients::BuildController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user, only: [:show]
  before_action :set_patient, only: [:show, :update]
  before_action :set_steps
  before_action :setup_wizard
  before_action :set_total_steps

  helper_method :wizard_with_params_path

  def show
    log_action Action::EVENTS[step_log_action], current_user, current_user, {url: request.path} unless step.to_sym == :wicked_finish
    @patient.ensure_basic_detail

    render_wizard
  end

  def update
    @patient.update_attributes(patient_params)
    flash.now[:alert] = @patient.error_message if @patient.errors.any?
    render_wizard @patient, {}, additional_params
  end

  def create
    @patient = Patient.create
    redirect_to wizard_path
  end

  def finish_wizard_path
    new_organization_visit_path(@patient.organization)
  end

  private

  def wizard_with_params_path
    wizard_path step, additional_params
  end

  def additional_params
    {
      only: params[:only]
    }
  end

  def patient_params
    params.require(:patient).permit(
      :email, :password, :first_name, :last_name, :date_of_birth, :password_confirmation,
      :phone, :source, :zip, :time_zone,
      basic_detail_attributes: [:gender, :patient_id, :client_unique_id, :address]
    )
  end

  def set_patient
    @patient = current_user
  end

  def set_steps
    organization_steps = [:zip, :dob, :timezone, :basics, :confirm]
    organization_steps = organization_steps.reject {|s| s == :confirm }
    organization_steps = organization_steps.reject {|s| s == :dob } unless @patient.organization.data_settings.dob
    organization_steps = organization_steps & params[:only].map(&:to_sym) if params[:only].present?

    self.steps = organization_steps
  end

  def set_total_steps
    @total_steps = steps.count
    @current_step = steps.index(step)
  end

  def step_log_action
    {
      zip: :patient_zip_create,
      dob: :patient_dob_create,
      timezone: :patient_time_zone_create,
      basics: :patient_basics_create
    }[step.to_sym]
  end
end
