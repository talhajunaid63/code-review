require 'test_helper'

class CoordinatorTest < ActiveSupport::TestCase
  setup do
    @coordinator = coordinators(:coordinator_46)
    @visit = visits(:visit_8)
    @patient = patients(:patient_44)
  end

  test "Coordinator.visits only returns visits assigned to coordinator." do
    count_before = @coordinator.visits.count
    @patient.coordinator_id = @coordinator.id
    @patient.save
    count_after = @coordinator.visits.count
    assert count_before < count_after
  end

end
