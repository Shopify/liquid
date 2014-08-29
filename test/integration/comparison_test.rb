require "test_helper"
PERF_DIR = File.dirname(__FILE__) + '/../../performance/shopify'
require PERF_DIR + '/comment_form'
require PERF_DIR + '/paginate'

class BlankTest < Minitest::Test
  def setup
    Liquid::Template.register_tag 'paginate', Paginate
    Liquid::Template.register_tag 'form', CommentForm
  end

  def teardown
    Liquid::Template.tags.delete('paginate')
    Liquid::Template.tags.delete('form')
  end

  def dump_template(t)
    Marshal.dump(t)
  end

  def compare_parsers(file)
    t, t2 = nil
    with_error_mode(:lax) do
      t = Liquid::Template.parse(file)
    end
    with_error_mode(:strict) do
      t2 = Liquid::Template.parse(file)
    end
    assert_equal dump_template(t), dump_template(t2)
  end

  def test_template_comparison
    Dir[File.dirname(__FILE__) + "/../../performance/tests/**/*.liquid"].each do |template|
      content = IO.read(template)
      compare_parsers(content)
    end
  end
end
