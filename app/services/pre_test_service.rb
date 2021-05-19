class PreTestService < ApplicationService
  attr_accessor :patient, :pre_test, :organization, :creator

  def initialize(patient: nil, organization: nil, creator: nil, pre_test: nil)
    @patient = patient
    @organization = organization
    @creator = creator
    @pre_test = pre_test
  end

  def perform
    @pre_test = organization.visits.add_pre_test_for(patient, creator)

    return Result.new(pre_test, false) unless pre_test.persisted?

    send_pre_test_email if patient.email?
    send_pre_test_sms if patient.phone?
    Result.new(pre_test, true)
  end

  def update(params)
    pre_test.assign_attributes(params.except(:codecs, :user_agent))

    if pre_test.changed? && pre_test.save
      notify_creator_via_phone if creator&.phone?
      notify_creator_via_email if creator&.email?
    end

    pre_test.pre_test_detail.update(codecs: params[:codecs], user_agent: params[:user_agent])
  end

  private

  def send_pre_test_email
    UserNotifierMailer.send_pre_test_email(patient_id: patient.id, pre_test_id: pre_test.id).deliver_later
  end

  def send_pre_test_sms
    path = pre_test.one_click_patient_login_visit_url(patient)
    content = "You have a visit pre test with #{pre_test.organization&.name}. Please enter visit room here: #{path.html_safe}"

    TextMessage.send_text(content, patient.phone)
  end

  def notify_creator_via_phone
    path = pre_test.pre_test_details_url
    content = "#{pre_test.patient.name}'s pre-test #{pre_test.success_category_status? ? 'Succeeded' : 'Failed'}. Details: #{path}"

    TextMessage.send_text(content, creator.phone)
  end

  def notify_creator_via_email
    UserNotifierMailer.notify_pre_test_creator(pre_test_id: pre_test.id).deliver_later
  end
end
