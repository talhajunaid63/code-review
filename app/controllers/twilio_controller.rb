class TwilioController < ApplicationController
  after_action :set_header
  before_action :authenticate_twilio_request, only: %i[connect_customer]
  before_action :set_patient, only: %i[connect_customer]

  def status
    voip_call_log = VoipCallLog.find_by(sid: params['ParentCallSid'])

    voip_call_log.update_data(params)

    head 200, content_type: 'text/html'
  end

  def connect_customer
    phone_number = @patient.phone
    VoipCallLog.create(sid: params['CallSid'], status: params['CallStatus'], visit: @visit, data: params)

    render_twiml TwilioService.make_call(phone_number, status_twilio_index_url)
  end

  private

  def authenticate_twilio_request
    return if TwilioService.valid_twilio_req?(request)

    response = Twilio::TwiML::VoiceResponse.new(&:hangup)

    render xml: response.to_s, status: :unauthorized
  end

  def set_patient
    @visit = Visit.find_by(id: params[:visit_id])
    return redirect_to root_path, alert: "In valid visit" if @visit.blank?

    @patient = @visit&.patient
    return redirect_to root_path, alert: "Please verify patient details." if @patient&.phone.blank?
  end

  def set_header
    response.headers["Content-Type"] = "text/xml"
  end

  def render_twiml(response)
    render plain: response.to_s
  end
end
