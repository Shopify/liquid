# frozen_string_literal: true

require 'test_helper'

class SelfDropTest < Minitest::Test
  include Liquid

  def test_self_drop_passed_as_render_param_preserves_original_scope
    source = <<~LIQUID
      {%- assign var = 42 -%}
      {%- assign s = self -%}
      {%- render "snippet1", other_self: s -%}
    LIQUID

    partials = {
      'snippet1' => <<~LIQUID,
        {%- assign var = 43 -%}
        {{- other_self.var }}|{{ self.var -}}
      LIQUID
    }

    assert_template_result('42|43', source, partials: partials)
  end

  def test_self_drop_in_render_without_passing_resolves_inner_scope
    source = <<~LIQUID
      {%- assign var = 42 -%}
      {%- render "snippet1" -%}
    LIQUID

    partials = {
      'snippet1' => <<~LIQUID,
        {%- assign var = 99 -%}
        {{- self.var -}}
      LIQUID
    }

    assert_template_result('99', source, partials: partials)
  end

  def test_self_drop_passed_to_nested_renders_preserves_each_level
    source = <<~LIQUID
      {%- assign a = 1 -%}
      {%- assign s1 = self -%}
      {%- render "snippet1", outer: s1 -%}
    LIQUID

    partials = {
      'snippet1' => <<~LIQUID,
        {%- assign a = 2 -%}
        {%- assign s2 = self -%}
        {%- render "snippet2", outer: outer, middle: s2 -%}
      LIQUID
      'snippet2' => <<~LIQUID,
        {%- assign a = 3 -%}
        {{- outer.a }}|{{ middle.a }}|{{ self.a -}}
      LIQUID
    }

    assert_template_result('1|2|3', source, partials: partials)
  end

  def test_self_drop_reflects_variables_assigned_after_creation
    source = <<~LIQUID
      {%- assign s = self -%}
      {%- assign x = 42 %}{{ s.x -}}
    LIQUID

    assert_template_result('42', source)
  end
end
