# frozen_string_literal: true

require 'test_helper'

class HybridTagUnitTest < Minitest::Test
  class TestHybridTag < Liquid::HybridTag
    private

    def render_self_closing_to_output_buffer(_context, output)
      output << "self-closing"
    end

    def render_block_form_to_output_buffer(context, output)
      output << "block["
      @body.render_to_output_buffer(context, output)
      output << "]"
    end
  end

  def setup
    @environment = Liquid::Environment.build do |env|
      env.tags = Liquid::Tags::STANDARD_TAGS.merge('hybrid' => TestHybridTag)
    end
  end

  def test_self_closing_form
    template = Liquid::Template.parse('{% hybrid %}', environment: @environment)
    assert_equal('self-closing', template.render)
  end

  def test_self_closing_block_form_predicate_is_false
    tag = parse_hybrid_tag('{% hybrid %}')
    refute(tag.block_form?)
  end

  def test_block_form
    template = Liquid::Template.parse('{% hybrid %}content{% endhybrid %}', environment: @environment)
    assert_equal('block[content]', template.render)
  end

  def test_block_form_predicate_is_true
    tag = parse_hybrid_tag('{% hybrid %}content{% endhybrid %}')
    assert(tag.block_form?)
  end

  def test_body_accessible_in_block_form
    tag = parse_hybrid_tag('{% hybrid %}hello world{% endhybrid %}')
    assert(tag.block_form?)
    assert_equal('hello world', tag.nodelist.map(&:to_s).join)
  end

  def test_self_closing_does_not_consume_tokens
    template = Liquid::Template.parse('{% hybrid %}after', environment: @environment)
    assert_equal('self-closingafter', template.render)
  end

  def test_self_closing_followed_by_block_form
    template = Liquid::Template.parse(
      '{% hybrid %}{% hybrid %}inner{% endhybrid %}',
      environment: @environment,
    )
    assert_equal('self-closingblock[inner]', template.render)
  end

  def test_block_form_followed_by_self_closing
    template = Liquid::Template.parse(
      '{% hybrid %}inner{% endhybrid %}{% hybrid %}',
      environment: @environment,
    )
    assert_equal('block[inner]self-closing', template.render)
  end

  def test_multiple_consecutive_self_closing
    template = Liquid::Template.parse(
      '{% hybrid %}{% hybrid %}{% hybrid %}',
      environment: @environment,
    )
    assert_equal('self-closingself-closingself-closing', template.render)
  end

  def test_multiple_consecutive_block_forms
    template = Liquid::Template.parse(
      '{% hybrid %}a{% endhybrid %}{% hybrid %}b{% endhybrid %}',
      environment: @environment,
    )
    assert_equal('block[a]block[b]', template.render)
  end

  def test_mixed_forms
    template = Liquid::Template.parse(
      '{% hybrid %}{% hybrid %}inner{% endhybrid %}{% hybrid %}',
      environment: @environment,
    )
    assert_equal('self-closingblock[inner]self-closing', template.render)
  end

  def test_self_closing_inside_block_tag
    template = Liquid::Template.parse(
      '{% if true %}{% hybrid %}{% endif %}',
      environment: @environment,
    )
    assert_equal('self-closing', template.render)
  end

  def test_block_form_inside_block_tag
    template = Liquid::Template.parse(
      '{% if true %}{% hybrid %}content{% endhybrid %}{% endif %}',
      environment: @environment,
    )
    assert_equal('block[content]', template.render)
  end

  def test_block_form_with_wrong_end_tag
    error = assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse(
        '{% hybrid %}content{% endwrong %}',
        environment: @environment,
      )
    end
    assert_match(/endwrong/, error.message)
  end

  def test_empty_block_form
    template = Liquid::Template.parse('{% hybrid %}{% endhybrid %}', environment: @environment)
    assert_equal('block[]', template.render)
  end

  def test_block_form_with_liquid_tags_in_body
    template = Liquid::Template.parse(
      '{% hybrid %}{% if true %}yes{% endif %}{% endhybrid %}',
      environment: @environment,
    )
    assert_equal('block[yes]', template.render)
  end

  def test_hybrid_tag_is_subclass_of_block
    assert(Liquid::HybridTag < Liquid::Block)
  end

  private

  def parse_hybrid_tag(source)
    template = Liquid::Template.parse(source, environment: @environment)
    template.root.nodelist.find { |node| node.is_a?(TestHybridTag) }
  end
end
