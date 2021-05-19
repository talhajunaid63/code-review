class StripeEvents::EventLoggerService
  def initialize(logger)
    @logger = logger
  end

  def call(event)
    @logger.info "STRIPE EVENT:#{event.type}:#{event.id}"
  end
end
