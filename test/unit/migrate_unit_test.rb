# frozen_string_literal: true

require 'test_helper'

class MigrateUnitTest < Minitest::Test
  def test_migrate_preserves_valid_markup
    [
      "{{a}}",
      " {{- \ta\n -}} ",
      "{{a.b['c'].d[5]|default:6,allow_false:true|truncate:7,'..'}}",
      "{{ a . b [ 'c' ] . d [ 5 ] | default : 6 , allow_false : true | truncate :  4 , '..'  }}",
      "{%assign x=a.b['c'].d[5]|default:6,allow_false:true|truncate:7,'..'%}",
      "{% assign x =\na . b [ 'c' ] . d [ 5 ] | default : 6 , allow_false : true | truncate :  4 , '..'  %}",
      "{% if a and b > c %}A{% elsif d or f contains g %}B{% else %}C{% endif %}",
      <<~LIQUID,
        {% liquid
          if x > 0
            assign x = x | plus: 1

          endif
        %}
      LIQUID
    ].each do |source|
      assert_no_migration(source)
    end
  end

  def test_migrate_variable
    with_error_mode(:lax) do
      assert_migration({
        %({{ ,|"' }}) => "{{  }}", # no MarkupWithQuotedFragment match, skipping characters
        %({{ ,|"' 123 }}) => "{{  123 }}", # MarkupWithQuotedFragment skipped characters
        "{{,-2}}" => "{{ -2}}", # preserve separators when removing ignored characters
        "{{  12 34  }}" => "{{  12  }}", # no FilterMarkupRegex match, skipping characters
        "{{ -12 34 | abs }}" => "{{ -12 | abs }}", # FilterMarkupRegex skipped characters
        %({{ -12 | '" abs }}) => "{{ -12 |  abs }}", # FilterParser skipped characters
        "{{ -1 | abs ' plus: 1 }}" => "{{ -1 | abs | plus: 1 }}", # FilterParser unexpected separator
        "{{ -1 | ! abs }}" => "{{ -1 | abs }}", # ignored non-word characters preceding filter name
        "{{ 'a' | append WAT: 'b' }}" => "{{ 'a' | append : 'b' }}", # FilterArgsRegex skipped characters
        "{{ '!' | replace, '!': '?' }}" => "{{ '!' | replace: '!', '?' }}", # FilterArgsRegex unexpected separators
        "{{ -a.1b }}" => "{{ ['-a']['1b'] }}", # quote separators when removing ignored characters
      })
    end
  end

  def test_migrate_expression
    with_error_mode(:lax) do
      assert_migration({
        "{{ (1.9...2.8) }}" => "{{ (1..2) }}", # apply constant range coercion
        "{{ 1.2.3.4 }}" => "{{ 1.2 }}", # multiple periods allowed by FLOATS_REGEX, truncated by to_f
        "{{ 1. }}" => "{{ 1.0 }}", # FLOATS_REGEX didn't require digits after the period
        "{{ .empty }}" => "{{ ['empty'] }}", # skipped character prevents exact literal lookup
      })
    end
  end

  def test_migrate_variable_lookup
    with_error_mode(:lax) do
      assert_migration({
        "{{@a[b].c@}}" => "{{ a[b].c }}", # VariableParser skipped characters
        "{{ a!b$c }}" => "{{ a.b.c }}", # VariableParser unexpected separators
      })
    end
  end

  def test_migrate_assign
    with_error_mode(:lax) do
      assert_migration({
        "{% assign!a = b!%}" => "{% assign a = b %}", # Syntax skipped characters
        "{% assign a = @b ! %}" => "{% assign a =  b %}", # Variable skipped characters
        "{% assign|x=1 %}" => "{% assign x=1 %}", # ensure tag name separated from markup
      })
    end
  end

  def test_lax_migrate_if
    with_error_mode(:lax) do
      assert_migration({
        "{% if@a@%}Y{% endif %}" => "{% if a %}Y{% endif %}", # Syntax skipped character
        "{% if &a contains^b and *c %}A{% elsif %d or$e %}B{% endif %}" =>
          "{% if  a contains b and  c %}A{% elsif  d or e %}B{% endif %}", # test more expressions
        "{% if b 1 %}Y{% endif %}" => "{% if b  %}Y{% endif %}", # missing operator with right operand
        "{% if c == %}Y{% endif %}" => "{% if c == nil %}Y{% endif %}", # operator with missing right operand
        "{% if!a!%}T{% endif %}" => "{% if a %}T{% endif %}", # VariableParser skipped characters
        "{% if!%}T{% endif %}" => "{% if nil %}T{% endif %}", # VariableParser skipping all characters
      })
    end
  end

  def test_migrate_liquid_tag
    with_error_mode(:lax) do
      source = <<~LIQUID
        {% liquid
          assign ! a = 1
          assign a = @b !
        %}
      LIQUID
      expect = <<~LIQUID
        {% liquid
          assign  a = 1
          assign a =  b
        %}
      LIQUID
      assert_migration({ source => expect })
    end
  end

  private

  def assert_migration(source_to_expected_output_hash)
    source_to_expected_output_hash.each do |source, expect|
      message = "source: #{source.inspect}"
      assert_equal(expect, Liquid::Template.migrate(source), message)
      assert_no_migration(expect)
      assert_equal(Liquid::Template.parse(expect, parse_mode: :strict).render!, Liquid::Template.parse(source).render!, message)
    end
  end
end
