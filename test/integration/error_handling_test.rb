# frozen_string_literal: true

require 'test_helper'

class ErrorHandlingTest < Minitest::Test
  include Liquid

  def test_templates_parsed_with_line_numbers_renders_them_in_errors
    template = <<-LIQUID
      Hello,

      {{ errors.standard_error }} will raise a standard error.

      Bla bla test.

      {{ errors.syntax_error }} will raise a syntax error.

      This is an argument error: {{ errors.argument_error }}

      Bla.
    LIQUID

    expected = <<-TEXT
      Hello,

      Liquid error (line 3): standard error will raise a standard error.

      Bla bla test.

      Liquid syntax error (line 7): syntax error will raise a syntax error.

      This is an argument error: Liquid error (line 9): argument error

      Bla.
    TEXT

    output = Liquid::Template.parse(template, line_numbers: true).render('errors' => ErrorDrop.new)
    assert_equal(expected, output)
  end

  def test_standard_error
    template = Liquid::Template.parse(' {{ errors.standard_error }} ')
    assert_equal(' Liquid error: standard error ', template.render('errors' => ErrorDrop.new))

    assert_equal(1, template.errors.size)
    assert_equal(StandardError, template.errors.first.class)
  end

  def test_syntax
    template = Liquid::Template.parse(' {{ errors.syntax_error }} ')
    assert_equal(' Liquid syntax error: syntax error ', template.render('errors' => ErrorDrop.new))

    assert_equal(1, template.errors.size)
    assert_equal(SyntaxError, template.errors.first.class)
  end

  def test_argument
    template = Liquid::Template.parse(' {{ errors.argument_error }} ')
    assert_equal(' Liquid error: argument error ', template.render('errors' => ErrorDrop.new))

    assert_equal(1, template.errors.size)
    assert_equal(ArgumentError, template.errors.first.class)
  end

  def test_missing_endtag_parse_time_error
    assert_match_syntax_error(/: 'for' tag was never closed\z/, ' {% for a in b %} ... ')
  end

  def test_unrecognized_operator
    with_error_mode(:strict) do
      assert_raises(SyntaxError) do
        Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ')
      end
    end
  end

  def test_lax_unrecognized_operator
    template = Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ', error_mode: :lax)
    assert_equal(' Liquid error: Unknown operator =! ', template.render)
    assert_equal(1, template.errors.size)
    assert_equal(Liquid::ArgumentError, template.errors.first.class)
  end

  def test_with_line_numbers_adds_numbers_to_parser_errors
    source = <<~LIQUID
      foobar

      {% "cat" | foobar %}

      bla
    LIQUID
    assert_match_syntax_error(/Liquid syntax error \(line 3\)/, source)
  end

  def test_with_line_numbers_adds_numbers_to_parser_errors_with_whitespace_trim
    source = <<~LIQUID
      foobar

      {%- "cat" | foobar -%}

      bla
    LIQUID

    assert_match_syntax_error(/Liquid syntax error \(line 3\)/, source)
  end

  def test_parsing_warn_with_line_numbers_adds_numbers_to_lexer_errors
    template = Liquid::Template.parse(
      '
        foobar

        {% if 1 =! 2 %}ok{% endif %}

        bla
            ',
      error_mode: :warn,
      line_numbers: true,
    )

    assert_equal(
      ['Liquid syntax error (line 4): Unexpected character = in "1 =! 2"'],
      template.warnings.map(&:message),
    )
  end

  def test_parsing_strict_with_line_numbers_adds_numbers_to_lexer_errors
    err = assert_raises(SyntaxError) do
      Liquid::Template.parse(
        '
          foobar

          {% if 1 =! 2 %}ok{% endif %}

          bla
                ',
        error_mode: :strict,
        line_numbers: true,
      )
    end

    assert_equal('Liquid syntax error (line 4): Unexpected character = in "1 =! 2"', err.message)
  end

  def test_syntax_errors_in_nested_blocks_have_correct_line_number
    source = <<~LIQUID
      foobar

      {% if 1 != 2 %}
        {% foo %}
      {% endif %}

      bla
    LIQUID

    assert_match_syntax_error("Liquid syntax error (line 4): Unknown tag 'foo'", source)
  end

  def test_strict_error_messages
    err = assert_raises(SyntaxError) do
      Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ', error_mode: :strict)
    end
    assert_equal('Liquid syntax error: Unexpected character = in "1 =! 2"', err.message)

    err = assert_raises(SyntaxError) do
      Liquid::Template.parse('{{%%%}}', error_mode: :strict)
    end
    assert_equal('Liquid syntax error: Unexpected character % in "{{%%%}}"', err.message)
  end

  def test_warnings
    template = Liquid::Template.parse('{% if ~~~ %}{{%%%}}{% else %}{{ hello. }}{% endif %}', error_mode: :warn)
    assert_equal(3, template.warnings.size)
    assert_equal('Unexpected character ~ in "~~~"', template.warnings[0].to_s(false))
    assert_equal('Unexpected character % in "{{%%%}}"', template.warnings[1].to_s(false))
    assert_equal('Expected id but found end_of_string in "{{ hello. }}"', template.warnings[2].to_s(false))
    assert_equal('', template.render)
  end

  def test_warning_line_numbers
    template = Liquid::Template.parse("{% if ~~~ %}\n{{%%%}}{% else %}\n{{ hello. }}{% endif %}", error_mode: :warn, line_numbers: true)
    assert_equal('Liquid syntax error (line 1): Unexpected character ~ in "~~~"', template.warnings[0].message)
    assert_equal('Liquid syntax error (line 2): Unexpected character % in "{{%%%}}"', template.warnings[1].message)
    assert_equal('Liquid syntax error (line 3): Expected id but found end_of_string in "{{ hello. }}"', template.warnings[2].message)
    assert_equal(3, template.warnings.size)
    assert_equal([1, 2, 3], template.warnings.map(&:line_number))
  end

  # Liquid should not catch Exceptions that are not subclasses of StandardError, like Interrupt and NoMemoryError
  def test_exceptions_propagate
    assert_raises(Exception) do
      template = Liquid::Template.parse('{{ errors.exception }}')
      template.render('errors' => ErrorDrop.new)
    end
  end

  def test_default_exception_renderer_with_internal_error
    template = Liquid::Template.parse('This is a runtime error: {{ errors.runtime_error }}', line_numbers: true)

    output = template.render('errors' => ErrorDrop.new)

    assert_equal('This is a runtime error: Liquid error (line 1): internal', output)
    assert_equal([Liquid::InternalError], template.errors.map(&:class))
  end

  def test_setting_default_exception_renderer
    old_exception_renderer = Liquid::Template.default_exception_renderer
    exceptions = []
    Liquid::Template.default_exception_renderer = ->(e) {
      exceptions << e
      ''
    }
    template = Liquid::Template.parse('This is a runtime error: {{ errors.argument_error }}')

    output = template.render('errors' => ErrorDrop.new)

    assert_equal('This is a runtime error: ', output)
    assert_equal([Liquid::ArgumentError], template.errors.map(&:class))
  ensure
    Liquid::Template.default_exception_renderer = old_exception_renderer if old_exception_renderer
  end

  def test_exception_renderer_exposing_non_liquid_error
    template   = Liquid::Template.parse('This is a runtime error: {{ errors.runtime_error }}', line_numbers: true)
    exceptions = []
    handler    = ->(e) {
      exceptions << e
      e.cause
    }

    output = template.render({ 'errors' => ErrorDrop.new }, exception_renderer: handler)

    assert_equal('This is a runtime error: runtime error', output)
    assert_equal([Liquid::InternalError], exceptions.map(&:class))
    assert_equal(exceptions, template.errors)
    assert_equal('#<RuntimeError: runtime error>', exceptions.first.cause.inspect)
  end

  class TestFileSystem
    def read_template_file(_template_path)
      "{{ errors.argument_error }}"
    end
  end

  def test_included_template_name_with_line_numbers
    old_file_system = Liquid::Template.file_system

    begin
      Liquid::Template.file_system = TestFileSystem.new

      template = Liquid::Template.parse("Argument error:\n{% include 'product' %}", line_numbers: true)
      page     = template.render('errors' => ErrorDrop.new)
    ensure
      Liquid::Template.file_system = old_file_system
    end
    assert_equal("Argument error:\nLiquid error (product line 1): argument error", page)
    assert_equal("product", template.errors.first.template_name)
  end

  def test_bug_compatible_silencing_of_errors_in_blank_nodes
    output = Liquid::Template.parse("{% assign x = 0 %}{% if 1 < '2' %}not blank{% assign x = 3 %}{% endif %}{{ x }}").render
    assert_equal("Liquid error: comparison of Integer with String failed0", output)

    output = Liquid::Template.parse("{% assign x = 0 %}{% if 1 < '2' %}{% assign x = 3 %}{% endif %}{{ x }}").render
    assert_equal("0", output)
  end

  def test_syntax_error_is_raised_with_template_name
    file_system = StubFileSystem.new("snippet" => "1\n2\n{{ 1")

    context = Liquid::Context.build(
      registers: { file_system: file_system },
    )

    template = Template.parse(
      '{% render "snippet" %}',
      line_numbers: true,
    )
    template.name = "template/index"

    assert_equal(
      "Liquid syntax error (snippet line 3): Variable '{{' was not properly terminated with regexp: /\\}\\}/",
      template.render(context),
    )
  end

  def test_syntax_error_is_raised_with_template_name_from_template_factory
    file_system = StubFileSystem.new("snippet" => "1\n2\n{{ 1")

    context = Liquid::Context.build(
      registers: {
        file_system: file_system,
        template_factory: StubTemplateFactory.new,
      },
    )

    template = Template.parse(
      '{% render "snippet" %}',
      line_numbers: true,
    )
    template.name = "template/index"

    assert_equal(
      "Liquid syntax error (some/path/snippet line 3): Variable '{{' was not properly terminated with regexp: /\\}\\}/",
      template.render(context),
    )
  end

  def test_error_is_raised_during_parse_with_template_name
    depth = Liquid::Block::MAX_DEPTH + 1
    code = "{% if true %}" * depth + "rendered" + "{% endif %}" * depth

    template = Template.parse("{% render 'snippet' %}", line_numbers: true)

    context = Liquid::Context.build(
      registers: {
        file_system: StubFileSystem.new("snippet" => code),
        template_factory: StubTemplateFactory.new,
      },
    )

    assert_equal("Liquid error (some/path/snippet line 1): Nesting too deep", template.render(context))
  end

  def test_internal_error_is_raised_with_template_name
    template = Template.new
    template.parse(
      "{% render 'snippet' %}",
      line_numbers: true,
    )
    template.name = "template/index"

    context = Liquid::Context.build(
      registers: {
        file_system: StubFileSystem.new({}),
      },
    )

    assert_equal(
      "Liquid error (template/index line 1): internal",
      template.render(context),
    )
  end
end
