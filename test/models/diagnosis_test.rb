require "test_helper"

describe Diagnosis do
  let(:diagnosis) { Diagnosis.new }

  it "must be valid" do
    value(diagnosis).must_be :valid?
  end
end
