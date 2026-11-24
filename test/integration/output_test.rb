# frozen_string_literal: true

require 'test_helper'

module FunnyFilter
  def make_funny(_input)
    'LOL'
  end

  def cite_funny(input)
    "LOL: #{input}"
  end

  def add_smiley(input, smiley = ":-)")
    "#{input} #{smiley}"
  end

  def add_tag(input, tag = "p", id = "foo")
    %(<#{tag} id="#{id}">#{input}</#{tag}>)
  end

  def paragraph(input)
    "<p>#{input}</p>"
  end

  def link_to(name, url)
    %(<a href="#{url}">#{name}</a>)
  end
end

class OutputTest < Minitest::Test
  include Liquid

  def setup
    @assigns = {
      'car' => { 'bmw' => 'good', 'gm' => 'bad' },
    }
  end

  def test_variable
    assert_template_result(" bmw ", " {{best_cars}} ", { "best_cars" => "bmw" })
  end

  def test_variable_traversing_with_two_brackets
    source = "{{ site.data.menu[include.menu][include.locale] }}"
    assert_template_result("it works!", source, {
      "site" => { "data" => { "menu" => { "foo" => { "bar" => "it works!" } } } },
      "include" => { "menu" => "foo", "locale" => "bar" },
    })
  end

  def test_variable_traversing
    source = " {{car.bmw}} {{car.gm}} {{car.bmw}} "
    assert_template_result(" good bad good ", source, @assigns)
  end

  def test_variable_piping
    text     = %( {{ car.gm | make_funny }} )
    expected = %( LOL )

    assert_equal(expected, Template.parse(text).render!(@assigns, filters: [FunnyFilter]))
  end

  def test_variable_piping_with_input
    text     = %( {{ car.gm | cite_funny }} )
    expected = %( LOL: bad )

    assert_equal(expected, Template.parse(text).render!(@assigns, filters: [FunnyFilter]))
  end

  def test_variable_piping_with_args
    text     = %! {{ car.gm | add_smiley : ':-(' }} !
    expected = %| bad :-( |

    assert_equal(expected, Template.parse(text).render!(@assigns, filters: [FunnyFilter]))
  end

  def test_variable_piping_with_no_args
    text     = %( {{ car.gm | add_smiley }} )
    expected = %| bad :-) |

    assert_equal(expected, Template.parse(text).render!(@assigns, filters: [FunnyFilter]))
  end

  def test_multiple_variable_piping_with_args
    text     = %! {{ car.gm | add_smiley : ':-(' | add_smiley : ':-('}} !
    expected = %| bad :-( :-( |

    assert_equal(expected, Template.parse(text).render!(@assigns, filters: [FunnyFilter]))
  end

  def test_variable_piping_with_multiple_args
    text     = %( {{ car.gm | add_tag : 'span', 'bar'}} )
    expected = %( <span id="bar">bad</span> )

    assert_equal(expected, Template.parse(text).render!(@assigns, filters: [FunnyFilter]))
  end

  def test_variable_piping_with_variable_args
    text     = %( {{ car.gm | add_tag : 'span', car.bmw}} )
    expected = %( <span id="good">bad</span> )

    assert_equal(expected, Template.parse(text).render!(@assigns, filters: [FunnyFilter]))
  end

  def test_multiple_pipings
    assigns = { 'best_cars' => 'bmw' }
    text     = %( {{ best_cars | cite_funny | paragraph }} )
    expected = %( <p>LOL: bmw</p> )

    assert_equal(expected, Template.parse(text).render!(assigns, filters: [FunnyFilter]))
  end

  def test_link_to
    text     = %( {{ 'Typo' | link_to: 'http://typo.leetsoft.com' }} )
    expected = %( <a href="http://typo.leetsoft.com">Typo</a> )

    assert_equal(expected, Template.parse(text).render!(@assigns, filters: [FunnyFilter]))
  end

  def test_binary_string_output_with_valid_utf8_bytes
    template = Template.parse("a{{ x }}é")
    output   = template.render("x" => (+"\xC2\xA3").b)

    assert_equal("a£é", output)
    assert_equal(Encoding::UTF_8, output.encoding)
    assert_empty(template.errors)
  end

  def test_binary_string_output_with_invalid_utf8_bytes
    template = Template.parse("a{{ x }}é")
    output   = template.render("x" => (+"\x80").b)

    assert_equal("aLiquid error: invalid byte sequence in UTF-8é", output)
    assert_equal(Encoding::UTF_8, output.encoding)
    assert_equal([Liquid::ArgumentError], template.errors.map(&:class))
  end

  def test_binary_string_output_from_base64_filters
    # https://github.com/Shopify/liquid/issues/1453
    template = Template.parse("a{{ '£' | base64_encode | base64_decode }}é")
    output   = template.render

    assert_equal("a£é", output)
    assert_equal(Encoding::UTF_8, output.encoding)
    assert_empty(template.errors)

    template = Template.parse("a{{ 'gA==' | base64_decode }}é")
    output   = template.render

    assert_equal("aLiquid error: invalid byte sequence in UTF-8é", output)
    assert_equal(Encoding::UTF_8, output.encoding)
    assert_equal([Liquid::ArgumentError], template.errors.map(&:class))
  end

  def test_binary_string_output_from_echo_cycle_and_custom_tags
    template = Template.parse("a{% echo x %}é")
    assert_equal("aLiquid error: invalid byte sequence in UTF-8é", template.render("x" => (+"\x80").b))

    template = Template.parse("a{% cycle x %}é")
    assert_equal("aLiquid error: invalid byte sequence in UTF-8é", template.render("x" => (+"\x80").b))

    environment = Liquid::Environment.build do |env|
      env.register_tag("binary", Class.new(Liquid::Tag) do
        def render(_context) = (+"\x80").b
      end)
    end

    template = Template.parse("a{% binary %}é", environment: environment)
    assert_equal("aLiquid error: invalid byte sequence in UTF-8é", template.render)
    assert_equal([Liquid::ArgumentError], template.errors.map(&:class))
  end

  def test_output_of_string_in_another_encoding_is_transcoded
    template = Template.parse("a{{ x }}é")

    assert_equal("ahié", template.render("x" => "hi".encode(Encoding::UTF_16LE)))
    assert_empty(template.errors)
  end

  def test_render_into_binary_output_buffer
    template = Template.parse("é{{ x }}")
    output   = +"".b

    template.render({ "x" => "✓" }, output: output)

    assert_equal("é✓".b, output)
  end
end # OutputTest
