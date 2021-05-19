class ApplicationService
  def self.perform(*args, &block)
    new(*args, &block).perform
  end

  private

  class Result
    attr_reader :resource, :message

    def initialize(resource, success, message = '')
      @resource = resource
      @success = success
      @message = message
    end

    def success?
      @success
    end
  end
  private_constant :Result
end
