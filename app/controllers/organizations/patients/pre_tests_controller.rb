# frozen_string_literal: true

class Organizations::Patients::PreTestsController < ApplicationController
  before_action :set_organization
  before_action :set_patient
  before_action :set_pre_test, only: %i[show update]

  def index
    @pre_tests = @organization.visits.pre_tests_for(@patient).page(params[:page]).per(Visit::PER_PAGE)

    authorize @pre_tests, policy_class: Organizations::Patients::PreTestPolicy
  end

  def new
    authorize @patient, policy_class: Organizations::Patients::PreTestPolicy

    result = PreTestService.perform(patient: @patient, organization: @organization, creator: current_user)
    pre_test = result.resource
    path = organization_patient_pre_tests_path(@organization, @patient)

    if pre_test.persisted?
      redirect_to path, notice: 'Pre-test successfully created and sent to patient.'
    else
      redirect_to path, alert: pre_test.errors.full_messages.to_sentence
    end
  end

  def show
    authorize @pre_test, policy_class: Organizations::Patients::PreTestPolicy

    @versions = @pre_test.versions.page(params[:versions_page]).per(5)
    @video_logs = @pre_test.video_logs.page(params[:video_logs_page]).per(5)
    @pre_test_detail = @pre_test.pre_test_detail
  end

  def update
    authorize @pre_test, policy_class: Organizations::Patients::PreTestPolicy

    PreTestService
      .new(pre_test: @pre_test, creator: @pre_test.pre_test_creator)
      .update(pre_test_params)

    head :ok
  end

  private

  def set_organization
    @organization = Organization.friendly.find params[:organization_id]
  end

  def set_patient
    @patient = Patient.find params[:patient_id]
  end

  def pre_test_params
    params.require(:pre_test).permit(:category_status, :user_agent, codecs: [])
  end

  def set_pre_test
    @pre_test = Visit.unscoped.find params[:id]
  end
end
