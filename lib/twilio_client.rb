class TwilioClient
  class << self

    def send_sms(to:, content:)
      client.messages.create(
        from: ApplicationConfig["TWILIO_NUMBER"],
        to: to,
        body: content
      )
    rescue Twilio::REST::TwilioError => e
      Rails.logger.info("Unable to send sms to #{to}: #{e.message}")
    end

    private

    def client
      Twilio::REST::Client.new(
        ApplicationConfig["TWILIO_SID"],
        ApplicationConfig["TWILIO_AUTH_TOKEN"]
      )
    end

  end
end
