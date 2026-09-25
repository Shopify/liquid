# frozen_string_literal: true

require_relative "../test_helper"

class TemplateRecorderDisabledTest < Minitest::Test
  def test_recording_fails_loudly_when_hooks_are_disabled
    skip if Liquid::TemplateRecorder::HOOKS_ENABLED

    error = assert_raises(Liquid::TemplateRecorder::Error) do
      Liquid::TemplateRecorder.record(Object.new) { flunk }
    end

    assert_match("set LIQUID_TEMPLATE_RECORDER_HOOKS before boot", error.message)
  end
end
