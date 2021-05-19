class ExportPreTestsService

  def initialize(pre_tests)
    @pre_tests = pre_tests
  end

  def process
    CSV.generate(headers: true) do |csv|
      csv << attributes

      @pre_tests.each do |pre_test|
        csv << data_for(pre_test)
      end
    end
  end

  def attributes
    [
      'id',
      'status',
      'pre_test_created',
      'pre_test_completed',
      'initiator',
      'patient',
      'browser'
    ]
  end

  def data_for(pre_test)
    pre_test_detail = pre_test.ensure_pre_test_detail
    [
      pre_test.id,
      status(pre_test),
      Utils.format_date(pre_test.created_at),
      Utils.format_date(pre_test_detail.attempted_at),
      pre_test_detail.user&.name,
      pre_test.patient.name,
      pre_test_detail.browser_info
    ]
  end

  def status(pre_test)
    pre_test_status = pre_test.category_status.titleize
    pre_test_status =  "#{pre_test_status}: #{pre_test.ensure_pre_test_detail.failed_reason}" if pre_test.failed_category_status?

    pre_test_status
  end

end
