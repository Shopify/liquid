# frozen_string_literal: true

require 'test_helper'

class PartialCacheUnitTest < Minitest::Test
  def test_uses_the_file_system_register_if_present
    context = Liquid::Context.build(
      registers: {
        file_system: StubFileSystem.new('my_partial' => 'my partial body'),
      }
    )

    partial = Liquid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Liquid::ParseContext.new,
      caller: :render
    )

    assert_equal('my partial body', partial.render)
  end

  def test_reads_from_the_file_system_only_once_per_file
    file_system = StubFileSystem.new('my_partial' => 'some partial body')
    context     = Liquid::Context.build(
      registers: { file_system: file_system }
    )

    2.times do
      Liquid::PartialCache.load(
        'my_partial',
        context: context,
        parse_context: Liquid::ParseContext.new,
        caller: :render
      )
    end

    assert_equal(1, file_system.file_read_count)
  end

  def test_cache_state_is_stored_per_context
    parse_context      = Liquid::ParseContext.new
    shared_file_system = StubFileSystem.new(
      'my_partial' => 'my shared value'
    )
    context_one = Liquid::Context.build(
      registers: {
        file_system: shared_file_system,
      }
    )
    context_two = Liquid::Context.build(
      registers: {
        file_system: shared_file_system,
      }
    )

    2.times do
      Liquid::PartialCache.load(
        'my_partial',
        context: context_one,
        parse_context: parse_context,
        caller: :render
      )
    end

    Liquid::PartialCache.load(
      'my_partial',
      context: context_two,
      parse_context: parse_context,
      caller: :render
    )

    assert_equal(2, shared_file_system.file_read_count)
  end

  def test_cache_is_not_broken_when_a_different_parse_context_is_used
    file_system = StubFileSystem.new('my_partial' => 'some partial body')
    context     = Liquid::Context.build(
      registers: { file_system: file_system }
    )

    Liquid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Liquid::ParseContext.new(my_key: 'value one'),
      caller: :render
    )
    Liquid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Liquid::ParseContext.new(my_key: 'value two'),
      caller: :render
    )

    # Technically what we care about is that the file was parsed twice,
    # but measuring file reads is an OK proxy for this.
    assert_equal(1, file_system.file_read_count)
  end

  def test_passes_caller_as_option_to_file_system
    context = Liquid::Context.build
    file_system = StubRestrictedFileSystem.new(
      restricted_callers: %i(include),
      values: { 'my_partial' => 'Inaccessible' }
    )
    context.registers[:file_system] = file_system

    partial = Liquid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Liquid::ParseContext.new,
      caller: :include
    )

    assert_equal('', partial.render)
    assert_equal(:include, file_system.last_caller)
  end

  def test_supports_legacy_file_system_without_method_read_template_file_with_options
    context = Liquid::Context.build
    file_system = StubLegacyFileSystem.new('my_partial' => 'my partial body')
    context.registers[:file_system] = file_system

    partial = Liquid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Liquid::ParseContext.new,
      caller: :render
    )

    assert_equal('my partial body', partial.render)
  end

  def test_caches_per_caller_type
    context = Liquid::Context.build
    file_system = StubRestrictedFileSystem.new(
      restricted_callers: %i(include),
      values: { 'my_partial' => 'my partial body' }
    )
    context.registers[:file_system] = file_system

    2.times do
      partial = Liquid::PartialCache.load(
        'my_partial',
        context: context,
        parse_context: Liquid::ParseContext.new,
        caller: :render
      )
      assert_equal('my partial body', partial.render)
    end

    partial = Liquid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Liquid::ParseContext.new,
      caller: :include
    )
    assert_equal('', partial.render)

    assert_equal(1, file_system.file_read_count)
  end
end
