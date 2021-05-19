require 'test_helper'

class TokBoxServiceTest < ActiveSupport::TestCase
  include OpenTokHelper

  setup do
    stubs_open_tok_create_session
    @visit_recording_enabled = visits(:visit_8)
    @visit_recording_not_enabled = visits(:visit_7)
  end

  test "TokBox Service sets recording if organization recording is enabled" do
    result = @visit_recording_enabled.update_open_tok_data
    assert result == true
  end

  test "TokBox Service does not set recording if organization recording is not enabled" do
    result = @visit_recording_not_enabled.update_open_tok_data
    assert result == true
  end
end
