# frozen_string_literal: true

require 'test_helper'
require 'liquid/traversal'

class TraversalTest < Minitest::Test
  include Liquid

  def test_variable
    assert_equal(
      ["test"],
      traversal(%({{ test }}))
    )
  end

  def test_varible_with_filter
    assert_equal(
      ["test", "infilter"],
      traversal(%({{ test | split: infilter }}))
    )
  end

  def test_dynamic_variable
    assert_equal(
      ["test", "inlookup"],
      traversal(%({{ test[inlookup] }}))
    )
  end

  def test_if_condition
    assert_equal(
      ["test"],
      traversal(%({% if test %}{% endif %}))
    )
  end

  def test_complex_if_condition
    assert_equal(
      ["test"],
      traversal(%({% if 1 == 1 and 2 == test %}{% endif %}))
    )
  end

  def test_if_body
    assert_equal(
      ["test"],
      traversal(%({% if 1 == 1 %}{{ test }}{% endif %}))
    )
  end

  def test_unless_condition
    assert_equal(
      ["test"],
      traversal(%({% unless test %}{% endunless %}))
    )
  end

  def test_complex_unless_condition
    assert_equal(
      ["test"],
      traversal(%({% unless 1 == 1 and 2 == test %}{% endunless %}))
    )
  end

  def test_unless_body
    assert_equal(
      ["test"],
      traversal(%({% unless 1 == 1 %}{{ test }}{% endunless %}))
    )
  end

  def test_elsif_condition
    assert_equal(
      ["test"],
      traversal(%({% if 1 == 1 %}{% elsif test %}{% endif %}))
    )
  end

  def test_complex_elsif_condition
    assert_equal(
      ["test"],
      traversal(%({% if 1 == 1 %}{% elsif 1 == 1 and 2 == test %}{% endif %}))
    )
  end

  def test_elsif_body
    assert_equal(
      ["test"],
      traversal(%({% if 1 == 1 %}{% elsif 2 == 2 %}{{ test }}{% endif %}))
    )
  end

  def test_else_body
    assert_equal(
      ["test"],
      traversal(%({% if 1 == 1 %}{% else %}{{ test }}{% endif %}))
    )
  end

  def test_case_left
    assert_equal(
      ["test"],
      traversal(%({% case test %}{% endcase %}))
    )
  end

  def test_case_condition
    assert_equal(
      ["test"],
      traversal(%({% case 1 %}{% when test %}{% endcase %}))
    )
  end

  def test_case_when_body
    assert_equal(
      ["test"],
      traversal(%({% case 1 %}{% when 2 %}{{ test }}{% endcase %}))
    )
  end

  def test_case_else_body
    assert_equal(
      ["test"],
      traversal(%({% case 1 %}{% else %}{{ test }}{% endcase %}))
    )
  end

  def test_for_in
    assert_equal(
      ["test"],
      traversal(%({% for x in test %}{% endfor %}))
    )
  end

  def test_for_limit
    assert_equal(
      ["test"],
      traversal(%({% for x in (1..5) limit: test %}{% endfor %}))
    )
  end

  def test_for_offset
    assert_equal(
      ["test"],
      traversal(%({% for x in (1..5) offset: test %}{% endfor %}))
    )
  end

  def test_for_body
    assert_equal(
      ["test"],
      traversal(%({% for x in (1..5) %}{{ test }}{% endfor %}))
    )
  end

  def test_tablerow_in
    assert_equal(
      ["test"],
      traversal(%({% tablerow x in test %}{% endtablerow %}))
    )
  end

  def test_tablerow_limit
    assert_equal(
      ["test"],
      traversal(%({% tablerow x in (1..5) limit: test %}{% endtablerow %}))
    )
  end

  def test_tablerow_offset
    assert_equal(
      ["test"],
      traversal(%({% tablerow x in (1..5) offset: test %}{% endtablerow %}))
    )
  end

  def test_tablerow_body
    assert_equal(
      ["test"],
      traversal(%({% tablerow x in (1..5) %}{{ test }}{% endtablerow %}))
    )
  end

  def test_cycle
    assert_equal(
      ["test"],
      traversal(%({% cycle test %}))
    )
  end

  def test_assign
    assert_equal(
      ["test"],
      traversal(%({% assign x = test %}))
    )
  end

  def test_capture
    assert_equal(
      ["test"],
      traversal(%({% capture x %}{{ test }}{% endcapture %}))
    )
  end

  def test_include
    assert_equal(
      ["test"],
      traversal(%({% include test %}))
    )
  end

  def test_include_with
    assert_equal(
      ["test"],
      traversal(%({% include "hai" with test %}))
    )
  end

  def test_include_for
    assert_equal(
      ["test"],
      traversal(%({% include "hai" for test %}))
    )
  end

  private

  def traversal(template)
    ParseTreeVisitor
      .for(Template.parse(template).root)
      .add_callback_for(VariableLookup, &:name)
      .visit.flatten.compact
  end
end
