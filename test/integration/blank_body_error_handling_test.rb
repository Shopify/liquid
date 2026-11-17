# frozen_string_literal: true

require 'test_helper'

class BlankBodyErrorHandlingTest < Minitest::Test
  COMPARISON_ERROR = 'Liquid error (line 1): comparison of Integer with String failed'
  INVALID_INTEGER_ERROR = 'Liquid error (line 1): invalid integer'

  def render_inline(source, assigns: {})
    Liquid::Template.parse(source, line_numbers: true).render(assigns, render_errors: true)
  end

  def assert_render_raises(source, assigns: {}, message: nil)
    error = assert_raises(Liquid::ArgumentError) do
      Liquid::Template.parse(source, line_numbers: true).render!(assigns)
    end
    assert_includes(error.message, message) if message
  end

  def test_blank_if_body_shows_inline_error_text
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}{% endif %}'))
  end

  def test_whitespace_if_body_shows_inline_error_text
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}   {% endif %}'))
  end

  def test_assign_if_body_shows_inline_error_text
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}{% assign a = 1 %}{% endif %}'))
  end

  def test_comment_if_body_shows_inline_error_text
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}{% comment %}c{% endcomment %}{% endif %}'))
  end

  def test_capture_if_body_shows_inline_error_text
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}{% capture c %}text{% endcapture %}{% endif %}'))
  end

  def test_blank_unless_body_shows_inline_error_text
    assert_equal(COMPARISON_ERROR, render_inline('{% unless 5 > "x" %} {% endunless %}'))
  end

  def test_blank_for_body_shows_inline_error_text
    assert_equal(INVALID_INTEGER_ERROR, render_inline('{% for i in (1..3) offset: xs %}{% endfor %}', assigns: { 'xs' => 'bad' }))
  end

  def test_nonblank_bodies_show_inline_error_text
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}{% echo 1 %}{% endif %}'))
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}{{ "" }}{% endif %}'))
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}{% else %}E{% endif %}'))
  end

  def test_raised_errors_are_not_swallowed_by_blank_if_body
    assert_render_raises('{% if 5 > "x" %}{% endif %}', message: 'comparison of Integer with String failed')
  end

  def test_raised_errors_are_not_swallowed_by_blank_for_body
    assert_render_raises('{% for i in (1..3) offset: xs %}{% endfor %}', assigns: { 'xs' => 'bad' }, message: 'invalid integer')
  end
end
