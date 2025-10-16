# frozen_string_literal: true

require 'test_helper'

class CaseTagUnitTest < Minitest::Test
  include Liquid

  def test_case_nodelist
    template = Liquid::Template.parse('{% case var %}{% when true %}WHEN{% else %}ELSE{% endcase %}')
    assert_equal(['WHEN', 'ELSE'], template.root.nodelist[0].nodelist.map(&:nodelist).flatten)
  end

  def test_case_with_trailing_element
    template = <<~LIQUID
      {%- case 1 bar -%}
        {%- when 1 -%}
          one
        {%- else -%}
          two
      {%- endcase -%}
    LIQUID

    [:lax, :strict].each do |mode|
      with_error_mode(mode) { assert_template_result("one", template) }
    end

    with_error_mode(:rigid) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }

      assert_match(/Expected end_of_string but found/, error.message)
    end
  end

  def test_case_when_trailing_element
    template = <<~LIQUID
      {%- case 1 -%}
        {%- when 1 bar -%}
          one
        {%- else -%}
          two
      {%- endcase -%}
    LIQUID

    [:lax, :strict].each do |mode|
      with_error_mode(mode) { assert_template_result("one", template) }
    end

    with_error_mode(:rigid) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }

      assert_match(/Expected end_of_string but found/, error.message)
    end
  end

  def test_case_when_with_comma
    template = <<~LIQUID
      {%- case 1 -%}
        {%- when 2, 1 -%}
          one
        {%- else -%}
          two
      {%- endcase -%}
    LIQUID

    [:lax, :strict, :rigid].each do |mode|
      with_error_mode(mode) { assert_template_result("one", template) }
    end
  end

  def test_case_when_with_or
    template = <<~LIQUID
      {%- case 1 -%}
        {%- when 2 or 1 -%}
          one
        {%- else -%}
          two
      {%- endcase -%}
    LIQUID

    [:lax, :strict, :rigid].each do |mode|
      with_error_mode(mode) { assert_template_result("one", template) }
    end
  end

  def test_case_with_invalid_expression
    template = <<~LIQUID
      {%- case foo=>bar -%}
        {%- when 'baz' -%}
          one
        {%- else -%}
          two
      {%- endcase -%}
    LIQUID
    assigns = { 'foo' => { 'bar' => 'baz' } }

    [:lax, :strict].each do |mode|
      with_error_mode(mode) do
        assert_template_result("one", template, assigns)
      end
    end

    with_error_mode(:rigid) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }

      assert_match(/Unexpected character =/, error.message)
    end
  end

  def test_case_when_with_invalid_expression
    template = <<~LIQUID
      {%- case 'baz' -%}
        {%- when foo=>bar -%}
          one
        {%- else -%}
          two
      {%- endcase -%}
    LIQUID
    assigns = { 'foo' => { 'bar' => 'baz' } }

    [:lax, :strict].each do |mode|
      with_error_mode(mode) do
        assert_template_result("one", template, assigns)
      end
    end

    with_error_mode(:rigid) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }

      assert_match(/Unexpected character =/, error.message)
    end
  end
end
