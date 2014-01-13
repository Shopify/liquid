require 'test_helper'

class CaseTagTest < Test::Unit::TestCase
  include Liquid

  def test_case_nodelist
    template = Liquid::Template.parse('{% case var %}{% when true %}WHEN{% else %}ELSE{% endcase %}')
    assert_equal ['WHEN', 'ELSE'], template.root.nodelist[0].nodelist
  end
end # CaseTest
