require 'test_helper'

class LayoutFileSystem
  def read_template_file(template_path, context)
    case template_path
    when "base"
      "<body>base</body>"

    when "inherited"
      "{% extends base %}"

    when "page_with_title"
      "<body><h1>{% block title %}Hello{% endblock %}</h1><p>Lorem ipsum</p></body>"

    when "product"
      "<body><h1>Our product: {{ name }}</h1>{% block info %}{% endblock %}</body>"

    when "product_with_warranty"
      "{% extends product %}{% block info %}<p>mandatory warranty</p>{% endblock %}"

    when "product_with_static_price"
      "{% extends product %}{% block info %}<h2>Some info</h2>{% block price %}<p>$42.00</p>{% endblock %}{% endblock %}"

    else
      template_path
    end
  end
end

class ExtendsTagTest < Test::Unit::TestCase
  include Liquid

  def setup
    Liquid::Template.file_system = LayoutFileSystem.new
  end

  def test_template_extends_another_template
    assert_template_result "<body>base</body>",
      "{% extends base %}"
  end

  def test_template_extends_an_inherited_template
    assert_template_result "<body>base</body>",
      "{% extends inherited %}"
  end

  def test_template_can_pass_variables_to_the_parent_template
    assert_template_result "<body><h1>Our product: Macbook</h1></body>",
      "{% extends product %}", 'name' => 'Macbook'
  end

  def test_template_can_pass_variables_to_the_inherited_parent_template
    assert_template_result "<body><h1>Our product: PC</h1><p>mandatory warranty</p></body>",
      "{% extends product_with_warranty %}", 'name' => 'PC'
  end

  def test_template_does_not_render_statements_outside_blocks
    assert_template_result "<body>base</body>",
      "{% extends base %} Hello world"
  end

  def test_template_extends_another_template_with_a_single_block
    assert_template_result "<body><h1>Hello</h1><p>Lorem ipsum</p></body>",
      "{% extends page_with_title %}"
  end

  def test_template_overrides_a_block
    assert_template_result "<body><h1>Sweet</h1><p>Lorem ipsum</p></body>",
      "{% extends page_with_title %}{% block title %}Sweet{% endblock %}"
  end

  def test_template_has_access_to_the_content_of_the_overriden_block
    assert_template_result "<body><h1>Hello world</h1><p>Lorem ipsum</p></body>",
      "{% extends page_with_title %}{% block title %}{{ block.super }} world{% endblock %}"
  end

  def test_template_accepts_nested_blocks
    assert_template_result "<body><h1>Our product: iPhone</h1><h2>Some info</h2><p>$42.00</p><p>(not on sale)</p></body>",
      "{% extends product_with_static_price %}{% block info/price %}{{ block.super }}<p>(not on sale)</p>{% endblock %}", 'name' => 'iPhone'
  end

end # ExtendsTagTest
