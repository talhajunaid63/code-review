class TwilioService
  def self.client_capability_token
    client_capability = Twilio::JWT::ClientCapability.new ApplicationConfig["TWILIO_SID"], ApplicationConfig["TWILIO_AUTH_TOKEN"]
    client_capability.add_scope(Twilio::JWT::ClientCapability::OutgoingClientScope.new ApplicationConfig["TWILIO_TWIML_SID"])

    client_capability.to_s
  end

  def self.make_call(phone_number, callback_url)
    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.dial(caller_id: ApplicationConfig["TWILIO_NUMBER"]) do |d|
        d.number( "+1#{phone_number}",
          status_callback_event: 'initiated ringing answered completed',
          status_callback: callback_url,
          status_callback_method: 'POST')
      end
    end

    response
  end

  def self.valid_twilio_req?(request)
    validator = Twilio::Security::RequestValidator.new(ApplicationConfig["TWILIO_AUTH_TOKEN"])

    url = request.original_url

    params = request.headers['rack.request.form_hash']
    signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
    validator.validate url, params, signature
  end

  # For future use if any
  # def self.hangup
  #   client = Twilio::REST::Client.new(ApplicationConfig["TWILIO_SID"], ApplicationConfig["TWILIO_AUTH_TOKEN"])
  #
  #   Needs current_call_id to hang up
  #   client.calls(current_call_id).update(status: 'completed')
  #   head :ok
  # end
end
