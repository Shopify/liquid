# frozen_string_literal: true

require 'test_helper'

class HybridTagUnitTest < Minitest::Test
  include Liquid

  class TestHybridTag < Liquid::HybridTag
    def blank?
      true
    end

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
      env.register_tag("hybrid", TestHybridTag)
    end
  end

  def test_hybrid_tag_is_subclass_of_block
    assert(TestHybridTag < Liquid::Block)
  end

  def test_self_closing_renders_correctly
    template = Liquid::Template.parse("{% hybrid %}", environment: @environment)
    assert_equal("self-closing", template.render)
  end

  def test_self_closing_block_form_predicate_is_false
    tag = parse_hybrid_tag("{% hybrid %}")
    refute(tag.block_form?)
  end

  def test_self_closing_does_not_consume_subsequent_tokens
    template = Liquid::Template.parse("{% hybrid %}after", environment: @environment)
    assert_equal("self-closingafter", template.render)
  end

  def test_block_form_renders_correctly
    template = Liquid::Template.parse("{% hybrid %}body{% endhybrid %}", environment: @environment)
    assert_equal("block[body]", template.render)
  end

  def test_block_form_predicate_is_true
    tag = parse_hybrid_tag("{% hybrid %}body{% endhybrid %}")
    assert(tag.block_form?)
  end

  def test_block_form_body_accessible_via_nodelist
    tag = parse_hybrid_tag("{% hybrid %}hello world{% endhybrid %}")
    assert(tag.block_form?)
    refute_empty(tag.nodelist)
    assert_equal("hello world", tag.nodelist.map(&:to_s).join)
  end

  def test_empty_block_form
    template = Liquid::Template.parse("{% hybrid %}{% endhybrid %}", environment: @environment)
    assert_equal("block[]", template.render)
  end

  def test_block_form_with_liquid_content
    template = Liquid::Template.parse(
      "{% hybrid %}before{{ var }}after{% endhybrid %}",
      environment: @environment,
    )
    assert_equal("block[beforeVafter]", template.render({ "var" => "V" }))
  end

  def test_sequential_block_forms
    template = Liquid::Template.parse(
      "{% hybrid %}a{% endhybrid %}{% hybrid %}b{% endhybrid %}",
      environment: @environment,
    )
    assert_equal("block[a]block[b]", template.render)
  end

  def test_self_closing_followed_by_block_form
    template = Liquid::Template.parse(
      "{% hybrid %}{% hybrid %}body{% endhybrid %}",
      environment: @environment,
    )
    assert_equal("self-closingblock[body]", template.render)
  end

  def test_block_form_followed_by_self_closing
    template = Liquid::Template.parse(
      "{% hybrid %}body{% endhybrid %}{% hybrid %}",
      environment: @environment,
    )
    assert_equal("block[body]self-closing", template.render)
  end

  def test_mixed_forms
    template = Liquid::Template.parse(
      "{% hybrid %}{% hybrid %}body{% endhybrid %}{% hybrid %}",
      environment: @environment,
    )
    assert_equal("self-closingblock[body]self-closing", template.render)
  end

  def test_self_closing_inside_block_tag
    template = Liquid::Template.parse(
      "{% if true %}{% hybrid %}{% endif %}",
      environment: @environment,
    )
    assert_equal("self-closing", template.render)
  end

  def test_block_form_inside_block_tag
    template = Liquid::Template.parse(
      "{% if true %}{% hybrid %}body{% endhybrid %}{% endif %}",
      environment: @environment,
    )
    assert_equal("block[body]", template.render)
  end

  def test_nested_same_type_raises_syntax_error
    error = assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse(
        "{% hybrid %}{% hybrid %}inner{% endhybrid %}{% endhybrid %}",
        environment: @environment,
      )
    end
    assert_match(/cannot be nested/, error.message)
  end

  def test_orphan_end_tag_raises_syntax_error
    error = assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse(
        "{% endhybrid %}",
        environment: @environment,
      )
    end
    assert_match(/no matching/, error.message)
  end

  private

  def parse_hybrid_tag(source)
    template = Liquid::Template.parse(source, environment: @environment)
    template.root.nodelist.find { |node| node.is_a?(TestHybridTag) }
  end
end
