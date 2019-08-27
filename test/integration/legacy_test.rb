# frozen_string_literal: true

require 'test_helper'
require 'liquid/legacy'

class FiltersTest < Minitest::Test
  include Liquid

  def test_constants
    assert_equal Liquid::FilterSeparator, Liquid::FILTER_SEPARATOR
    assert_equal Liquid::BlockBody::ContentOfVariable, Liquid::BlockBody::CONTENT_OF_VARIABLE
  end
end
