require "test_helper"

describe Cpt do
  let(:cpt) { Cpt.new }

  it "must be valid" do
    value(cpt).must_be :valid?
  end
end
