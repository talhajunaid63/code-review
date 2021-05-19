require "test_helper"

describe VisitDetail do
  let(:visit_detail) { VisitDetail.new }

  it "must be valid" do
    value(visit_detail).must_be :valid?
  end
end
