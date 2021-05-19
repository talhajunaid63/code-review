module PatientHelper
  def pre_test_category_status(patient)
    status = patient&.pre_test&.category_status&.titleize
    return if status.blank?

    "(#{status})"
  end
end
