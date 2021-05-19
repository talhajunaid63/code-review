class OrgSetups::PatientImportsController < ApplicationController
  before_action :set_org_setup, :set_organization
  before_action :set_patients, only: %i[new create]
  before_action :valid_import_validation, only: :create

  def new
    @patient_import = Organization::PatientImport.new
  end

  def create
    if params[:finish]
      @org_setup.update_column(:step, 8)
      redirect_to OrganizationOnboardingService.new(@org_setup).next_step
      return
    end

    result = ImportSummaryService.new(import_params[:csv_file], current_user, @organization, Organization::PATIENT).process
    summary = result.resource
    if result.success?
      @org_setup.update_column(:step, 8)
      redirect_to OrganizationOnboardingService.new(@org_setup).next_step, notice: "Patients/Clients import is in progress, you can continue setting up the organization meanwhile."
    else
      flash.now[:alert] = summary.errors.full_messages.to_sentence
      render :new
    end
  end

  private

  def import_params
    params.require(:organization_patient_import).permit(:csv_file, :organization_id)
  end

  def set_org_setup
    @org_setup = OrgSetup.find(params[:org_setup_id])
  end

  def set_organization
    @organization = @org_setup.organization
  end

  def set_patients
    @patients =
      FindPatientsQuery
      .new(@organization.patients)
      .call(organization_id: @organization.id).order(created_at: :desc)
      .page(params[:page]).per(Patient::PER_PAGE)
  end

  def valid_import_validation
    return if params[:finish]

    file_exist = import_params[:csv_file].present?
    no_running_import = UserImport.for_organization(@organization).pending_or_running.blank?
    return if file_exist && no_running_import

    flash[:alert] = 'CSV File is required to import' unless file_exist
    flash[:alert] = 'Only one CSV file can be imported at a time.' unless no_running_import
    return redirect_to new_org_setup_patient_import_path(@org_setup)
  end
end
