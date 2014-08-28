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
    t.inspect.gsub(/:0x[a-f0-9]+/, "")
  end

  def compare_parsers(file)
    Liquid::Template.error_mode = :lax
    t = Liquid::Template.parse(file)
    Liquid::Template.error_mode = :strict
    t2 = Liquid::Template.parse(file)
    assert_equal dump_template(t), dump_template(t2)
  end

  def test_template_comparison
    Dir[File.dirname(__FILE__) + "/../../performance/tests/**/*.liquid"].each do |template|
      content = IO.read(template)
      compare_parsers(content)
    end
  end
end
