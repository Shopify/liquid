# frozen_string_literal: true

require_relative "../test_helper"
require "tmpdir"

class TemplateRecorderTest < Minitest::Test
  class ProductDrop < Liquid::Drop
    def initialize(title, secret)
      super()
      @title = title
      @secret = secret
    end

    attr_reader :title

    def details
      DetailsDrop.new
    end
  end

  class DetailsDrop < Liquid::Drop
    def count
      3
    end
  end

  class LegacyFileSystem
    attr_reader :reads

    def initialize
      @reads = []
    end

    def read_template_file(name)
      @reads << name
      "partial={{ product.title }}"
    end
  end

  class UnsupportedLiquidValue
    def to_liquid
      self
    end

    def to_s
      "unsupported"
    end
  end

  class WrapperTag < Liquid::Block
  end

  class MarkerTag < Liquid::Tag
    def render(_context)
      "custom"
    end
  end

  class CollectingWriter
    attr_reader :records

    def initialize
      @records = []
    end

    def write(record)
      @records << record
    end
  end

  def setup
    @directory = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def path(name = "recording.json")
    File.join(@directory, name)
  end

  def test_records_and_verifies_a_render_without_changing_drop_behavior
    product = ProductDrop.new("Computed", "must not be recorded")
    template_source = "{{ product.title }} ({{ product.details.count }})"

    output = Liquid::TemplateRecorder.record(path) do
      Liquid::Template.parse(template_source).render!("product" => product)
    end

    assert_equal("Computed (3)", output)
    record = Liquid::TemplateRecorder.records(path).first
    assert_equal({ "title" => "Computed", "details" => { "count" => 3 } }, record.dig("assigns", "product"))
    refute_includes(File.read(path), "must not be recorded")
    assert_equal(output, Liquid::TemplateRecorder.replay_from(path, mode: :verify).render)
  end

  def test_preserves_the_legacy_one_argument_file_system_contract
    file_system = LegacyFileSystem.new
    environment = Liquid::Environment.build { |env| env.file_system = file_system }

    output = Liquid::TemplateRecorder.record(path) do
      Liquid::Template.parse("before {% include 'card' %}", environment: environment)
        .render!("product" => ProductDrop.new("Hat", "secret"))
    end

    assert_equal("before partial=Hat", output)
    assert_equal(["card"], file_system.reads)
    record = Liquid::TemplateRecorder.records(path).first
    assert_equal({ "card" => "partial={{ product.title }}" }, record["file_system"])
    assert_equal(2, record["templates"].length)
    assert_equal(output, Liquid::TemplateRecorder.replay_from(path, mode: :verify).render)
  end

  def test_jsonl_appends_one_self_contained_record_per_render
    recording = path("renders.jsonl")

    2.times do |sequence|
      Liquid::TemplateRecorder.record(recording) do
        Liquid::Template.parse("value={{ value }}").render!("value" => sequence)
      end
    end

    assert_equal(2, File.readlines(recording).length)
    assert_equal(["value=0", "value=1"], Liquid::TemplateRecorder.records(recording).map { |item| item["output"] })
    assert_equal("value=0", Liquid::TemplateRecorder.replay_from(recording, index: 0).render)
    assert_equal("value=1", Liquid::TemplateRecorder.replay_from(recording).render)
  end

  def test_json_session_supports_multiple_renders
    Liquid::TemplateRecorder.record(path) do
      Liquid::Template.parse("one={{ value }}").render!("value" => 1)
      Liquid::Template.new.parse("two={{ value }}").render!("value" => 2)
    end

    records = Liquid::TemplateRecorder.records(path)
    assert_equal(["one=1", "two=2"], records.map { |item| item["output"] })
    assert_equal("two=2", Liquid::TemplateRecorder.replay_from(path).render)
  end

  def test_failed_recording_does_not_delete_an_existing_json_file
    File.write(path, "existing")

    assert_raises(RuntimeError) do
      Liquid::TemplateRecorder.record(path) { raise "boom" }
    end

    assert_equal("existing", File.read(path))
  end

  def test_render_failure_is_not_written_to_jsonl
    recording = path("renders.jsonl")

    assert_raises(Liquid::UndefinedVariable) do
      Liquid::TemplateRecorder.record(recording) do
        Liquid::Template.parse("{{ missing }}").render!(nil, strict_variables: true)
      end
    end

    refute_path_exists(recording)
  end

  def test_tampered_template_is_rejected
    Liquid::TemplateRecorder.record(path) { Liquid::Template.parse("safe").render! }
    session = JSON.parse(File.read(path))
    session["renders"][0]["template"]["source"] = "changed"
    File.write(path, JSON.generate(session))

    error = assert_raises(Liquid::TemplateRecorder::ReplayError) do
      Liquid::TemplateRecorder.replay_from(path)
    end
    assert_match(/checksum/, error.message)
  end

  def test_recordings_are_thread_local
    paths = [path("a.json"), path("b.json")]
    ready = Queue.new
    release = Queue.new
    threads = Array.new(2) do |index|
      Thread.new do
        Liquid::TemplateRecorder.record(paths[index]) do
          ready << true
          release.pop
          Liquid::Template.parse("thread={{ value }}").render!("value" => index)
        end
      end
    end
    2.times { ready.pop }
    2.times { release << true }
    threads.each(&:join)

    assert_equal("thread=0", Liquid::TemplateRecorder.records(paths[0]).first["output"])
    assert_equal("thread=1", Liquid::TemplateRecorder.records(paths[1]).first["output"])
  end

  def test_nested_sessions_fail_without_corrupting_outer_session
    error = nil
    Liquid::TemplateRecorder.record(path) do
      error = assert_raises(Liquid::TemplateRecorder::Error) do
        Liquid::TemplateRecorder.record(path("inner.json")) { flunk }
      end
      Liquid::Template.parse("outer").render!
    end

    assert_match(/nested/, error.message)
    assert_equal("outer", Liquid::TemplateRecorder.replay_from(path).render)
  end

  def test_supported_render_argument_forms_keep_working
    filter = Module.new do
      def decorate(input)
        "[#{input}]"
      end
    end
    template = nil
    context = Liquid::Context.new([{ "value" => "context" }])

    Liquid::TemplateRecorder.record(path) do
      template = Liquid::Template.parse("{{ value | decorate }}")
      assert_equal("[hash]", template.render({ "value" => "hash" }, filter))
      context.add_filters(filter)
      assert_equal("[context]", template.render(context))
    end

    assert_equal(2, Liquid::TemplateRecorder.records(path).length)
  end

  def test_strict_replay_uses_exact_recorded_filter_outputs
    filter = Module.new do
      def external_lookup(_input)
        "x" * 150
      end
    end

    output = Liquid::TemplateRecorder.record(path) do
      Liquid::Template.parse("{{ key | external_lookup }}").render!({ "key" => "a" }, filter)
    end

    assert_equal("x" * 150, output)
    assert_equal(output, Liquid::TemplateRecorder.replay_from(path, mode: :strict).render)
    assert_equal("a", Liquid::TemplateRecorder.replay_from(path, mode: :compute).render)
  end

  def test_jsonl_reader_ignores_only_a_truncated_final_record
    recording = path("renders.jsonl")
    Liquid::TemplateRecorder.record(recording) { Liquid::Template.parse("complete").render! }
    File.open(recording, "ab") { |file| file.write('{"format":') }

    assert_equal(["complete"], Liquid::TemplateRecorder.records(recording).map { |item| item["output"] })
  end

  def test_accepts_a_pluggable_writer
    writer = CollectingWriter.new

    output = Liquid::TemplateRecorder.record(writer) do
      Liquid::Template.parse("Hello {{ name }}").render!("name" => "Shopify")
    end

    assert_equal("Hello Shopify", output)
    assert_equal(["Hello Shopify"], writer.records.map { |record| record["output"] })
  end

  def test_records_only_variables_resolved_by_the_template
    unused = Object.new
    assigns = { "visible" => "yes", "unused" => unused }

    Liquid::TemplateRecorder.record(path) do
      Liquid::Template.parse("{{ visible }}").render!(assigns)
    end

    assert_equal({ "visible" => "yes" }, Liquid::TemplateRecorder.records(path).first["assigns"])
  end

  def test_recording_scope_is_fiber_local
    writer = CollectingWriter.new
    ordinary_output = nil

    Liquid::TemplateRecorder.record(writer) do
      Fiber.new do
        ordinary_output = Liquid::Template.parse("ordinary").render!
      end.resume
      Liquid::Template.parse("recorded").render!
    end

    assert_equal("ordinary", ordinary_output)
    assert_equal(["recorded"], writer.records.map { |record| record["output"] })
  end

  def test_on_error_keeps_recording_failures_out_of_the_render_path
    writer = Object.new
    writer.define_singleton_method(:write) { |_record| raise "sink unavailable" }
    errors = []

    output = Liquid::TemplateRecorder.record(writer, on_error: errors.method(:<<)) do
      Liquid::Template.parse("still rendered").render!
    end

    assert_equal("still rendered", output)
    assert_equal(["sink unavailable"], errors.map(&:message))
  end

  def test_unsupported_accessed_values_do_not_affect_the_render
    value = UnsupportedLiquidValue.new
    writer = CollectingWriter.new

    output = Liquid::TemplateRecorder.record(writer) do
      Liquid::Template.parse("{{ value }}").render!("value" => value)
    end

    assert_equal(value.to_s, output)
    assert_equal({}, writer.records.first["assigns"])
  end

  def test_strict_replay_accepts_the_application_environment
    environment = Liquid::Environment.build(
      tags: Liquid::Environment.default.tags.merge("marker" => MarkerTag),
    )
    writer = CollectingWriter.new
    Liquid::TemplateRecorder.record(writer) do
      Liquid::Template.parse("{% marker %}", environment: environment).render!
    end

    replay = Liquid::TemplateRecorder::Replayer.new(
      writer.records.first,
      mode: :strict,
      environment: environment,
    )

    assert_equal("custom", replay.render)
  end

  def test_captures_file_reads_that_happen_before_the_template_starts_rendering
    writer = CollectingWriter.new
    Liquid::TemplateRecorder.record(writer) do
      Liquid::TemplateRecorder.current.emit_file_read("card", "Card")
      file_system = LegacyFileSystem.new
      Liquid::Template.parse("{% render 'card' %}").render!({}, registers: { file_system: file_system })
    end

    replay = Liquid::TemplateRecorder::Replayer.new(writer.records.first, mode: :strict)

    assert_equal("partial=", replay.render)
  end

  def test_strict_replay_skips_nested_custom_tag_calls
    environment = Liquid::Environment.build(
      tags: Liquid::Environment.default.tags.merge("wrapper" => WrapperTag, "marker" => MarkerTag),
    )
    writer = CollectingWriter.new
    Liquid::TemplateRecorder.record(writer) do
      Liquid::Template.parse("{% wrapper %}{% marker %}{% endwrapper %}", environment: environment).render!
    end

    record = writer.records.first
    replay = Liquid::TemplateRecorder::Replayer.new(record, mode: :strict, environment: environment)

    assert_equal(["wrapper"], record["tag_calls"].map { |call| call["name"] })
    assert_equal("custom", replay.render)
  end
end
