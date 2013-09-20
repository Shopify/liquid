require 'test_helper'

class ExtendTestFileSystem
  def read_template_file(template_path, context)
    case template_path
    when "base"
      "<body>base</body>"

    else
      template_path
    end
  end
end


class ExtendTagTest < Test::Unit::TestCase
  include Liquid

  def setup
    Liquid::Template.file_system = ExtendTestFileSystem.new
  end

  def test_extend
    assert_equal "<body>base</body>", Template.parse("{% extend base %}").render
  end
end
