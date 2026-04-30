# frozen_string_literal: true

require 'test_helper'

# Tests for self[var] lookup behavior across {% render %} boundaries,
# including the `self:` bound-parameter shape used by the rewriter.
class SelfDropRenderTest < Minitest::Test
  include Liquid

  # Snippet body using the rewriter's `self[name_var]` form. `item_1_title`
  # is a template-local assign; `name` is built at runtime; the rewriter
  # produces `self[name]` because bare brackets are forbidden in :strict2.
  REWRITTEN_SNIPPET = <<~LIQUID
    {%- liquid
      assign item_1_title = 'Cookware Set'
    -%}
    {%- for i in (1..1) -%}
      {%- liquid
        assign name = 'item_' | append: i | append: '_title'
        assign title = self[name]
      -%}
      [{{ title }}]
    {%- endfor -%}
  LIQUID

  # Original (pre-rewrite) snippet body using bare-bracket lookup. Rejected
  # at parse time by :strict2 -- which is why the rewriter exists.
  ORIGINAL_SNIPPET = <<~LIQUID
    {%- liquid
      assign item_1_title = 'Cookware Set'
    -%}
    {%- for i in (1..1) -%}
      {%- liquid
        assign name = 'item_' | append: i | append: '_title'
        assign title = [name]
      -%}
      [{{ title }}]
    {%- endfor -%}
  LIQUID

  EXPECTED_OUTPUT = '[Cookware Set]'

  # Baseline: parent does NOT pass `self:` to the snippet. The SelfDrop is
  # returned by find_variable (no scope has the `self` key), and its `[]`
  # walks back through the scope chain to find the for-loop-local
  # `item_1_title`. This is the parity-safe case for the rewriter's
  # transform; passing today.
  def test_rewritten_self_lookup_without_self_named_param_resolves_local_assign
    assert_template_result(
      EXPECTED_OUTPUT,
      "{% render 'snippet' %}",
      partials: { 'snippet' => REWRITTEN_SNIPPET },
      error_mode: :strict2,
    )
  end

  # PRODUCTION FAILURE SHAPE.
  #
  # Parent passes `self:` as a named render parameter. Render's
  # `inner_context[key] = context.evaluate(value)` (render.rb:68-70)
  # writes `my_obj` to `inner_context['self']`, which lands in
  # @scopes[0] (context.rb:172-174). Now find_variable's check at
  # context.rb:209-213 sees `self` defined in scope[0] and skips the
  # SelfDrop fallthrough -- `self[name]` becomes a literal key-access
  # against `my_obj`, which has no `item_1_title` key, returning nil.
  # Output is empty.
  #
  # This test asserts the INTENDED behavior (output should be the
  # snippet-local title). It FAILS today. It should pass once the
  # rewriter's transform is corrected to preserve scope-chain semantics
  # across `{% render 'snippet', self: ... %}` boundaries (or, less
  # likely, once SelfDrop's lookup precedence is changed in
  # find_variable).
  #
  # Failure message reads:
  #   Expected: "[Cookware Set]"
  #     Actual: "[]"
  # which directly says "the snippet's template-local item_1_title was
  # not found via self[name] when self: was bound on render".
  def test_rewritten_self_lookup_with_self_named_param_loses_local_assign
    assert_template_result(
      EXPECTED_OUTPUT,
      "{% render 'snippet', self: my_obj %}",
      { 'my_obj' => { 'unrelated_key' => 'foo' } },
      partials: { 'snippet' => REWRITTEN_SNIPPET },
      error_mode: :strict2,
    )
  end

  # Pins the prohibition that motivates the rewriter migration:
  # bare-bracket access must raise at parse time in :strict2. Documents
  # WHY the rewriter rewrites `[name]` to `self[name]` in the first
  # place. Passing today; serves as a guard against accidental
  # regression of PR #2060's strict2 enforcement.
  def test_original_bare_bracket_lookup_raises_in_strict2
    error = assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse(ORIGINAL_SNIPPET, error_mode: :strict2)
    end
    assert_match(
      /Bare bracket access is not allowed\. Use self\['\.\.\.'\] instead/,
      error.message,
    )
  end

  # Coverage extension: the bug is not a one-off of the empty-string-built
  # variable name. Confirm `self[name]` still misses when `name` is sourced
  # directly from the forloop index (no string concatenation), so a future
  # rewriter fix cannot accidentally pass tests by special-casing
  # constructed strings.
  #
  # `forloop.index` is a number; we cast to string via `| append: ''` to
  # form `item_1_title` in a different way. Same expected failure: empty
  # output today, should be `[Cookware Set]` once fixed.
  def test_rewritten_self_lookup_with_forloop_constructed_key_loses_local_assign
    snippet = <<~LIQUID
      {%- liquid
        assign item_1_title = 'Cookware Set'
      -%}
      {%- for i in (1..1) -%}
        {%- assign suffix = forloop.index | append: '_title' -%}
        {%- assign name = 'item_' | append: suffix -%}
        {%- assign title = self[name] -%}
        [{{ title }}]
      {%- endfor -%}
    LIQUID

    assert_template_result(
      EXPECTED_OUTPUT,
      "{% render 'snippet', self: my_obj %}",
      { 'my_obj' => { 'unrelated_key' => 'foo' } },
      partials: { 'snippet' => snippet },
      error_mode: :strict2,
    )
  end

  # If it fails: Inner snippet's SelfDrop saw outer bound self OR outer locals;
  # isolation broken.
  def test_nested_render_each_level_resolves_its_own_local_via_bound_self
    snippet_a = <<~LIQUID
      {%- assign label_a = 'A_local' -%}
      {%- assign key_a = 'label_a' -%}
      A=[{{ self[key_a] }}]{% render 'b', self: obj_b %}
    LIQUID
    snippet_b = <<~LIQUID
      {%- assign label_b = 'B_local' -%}
      {%- assign key_b = 'label_b' -%}
      B=[{{ self[key_b] }}]
    LIQUID
    parent = "{% render 'a', self: obj_a %}"
    assigns = {
      'obj_a' => { 'unrelated_a' => 'xa' },
      'obj_b' => { 'unrelated_b' => 'xb' },
    }
    assert_template_result(
      "A=[A_local]B=[B_local]\n\n",
      parent,
      assigns,
      partials: { 'a' => snippet_a, 'b' => snippet_b },
      error_mode: :strict2,
    )
  end

  # If it fails: Bound self leaked across `new_isolated_subcontext` boundary;
  # SelfDrop carries state across subcontexts.
  def test_nested_render_inner_without_self_walks_only_inner_scope
    snippet_a = <<~LIQUID
      {%- assign label_a = 'A_local' -%}
      A=[{{ self['label_a'] }}]{% render 'b' %}
    LIQUID
    snippet_b = <<~LIQUID
      {%- assign label_b = 'B_local' -%}
      {%- assign key_b = 'label_b' -%}
      B=[{{ self[key_b] }}]
    LIQUID
    parent = "{% render 'a', self: obj_a %}"
    assigns = { 'obj_a' => { 'label_b' => 'LEAK_FROM_OBJ_A' } }
    assert_template_result(
      "A=[A_local]B=[B_local]\n\n",
      parent,
      assigns,
      partials: { 'a' => snippet_a, 'b' => snippet_b },
      error_mode: :strict2,
    )
  end

  # If it fails: Specific segment in concatenated output names the broken layer
  # (top-level, snippet_a local, snippet_a bound, snippet_b local, snippet_b
  # bound).
  def test_full_chain_top_level_plus_nested_renders_with_mixed_self_binding
    snippet_a = <<~LIQUID
      {%- assign a_local = 'A!' -%}
      {%- assign a_key = 'a_local' -%}
      [a:{{ self[a_key] }}|reg:{{ regular_var }}|bound:{{ self['shared'] }}]{% render 'b', self: obj_b %}
    LIQUID
    snippet_b = <<~LIQUID
      {%- assign b_local = 'B!' -%}
      {%- assign b_key = 'b_local' -%}
      [b:{{ self[b_key] }}|bound:{{ self['only_in_b'] }}]
    LIQUID
    template = <<~LIQUID
      {%- assign top_key = 'top_var' -%}
      top:{{ self[top_key] }}|lit:LITERAL|{% render 'a', self: obj_a, regular_var: 'REG' %}
    LIQUID
    assigns = {
      'top_var' => 'TOP!',
      'obj_a' => { 'shared' => 'SHARED_A' },
      'obj_b' => { 'only_in_b' => 'B_BOUND', 'shared' => 'SHARED_B_NOT_USED' },
    }
    expected = "top:TOP!|lit:LITERAL|[a:A!|reg:REG|bound:SHARED_A][b:B!|bound:B_BOUND]\n\n\n"
    assert_template_result(
      expected,
      template,
      assigns,
      partials: { 'a' => snippet_a, 'b' => snippet_b },
      error_mode: :strict2,
    )
  end

  # If it fails: Lookup precedence flipped from bound-first to scope-first;
  # section C invariant lost.
  def test_bound_self_key_hit_returns_bound_value_not_scope_value
    snippet = <<~LIQUID
      {%- assign shared = 'SCOPE_VALUE' -%}
      [{{ self['shared'] }}]
    LIQUID
    assert_template_result(
      "[BOUND_VALUE]\n",
      "{% render 'snippet', self: my_obj %}",
      { 'my_obj' => { 'shared' => 'BOUND_VALUE' } },
      partials: { 'snippet' => snippet },
      error_mode: :strict2,
    )
  end
end
