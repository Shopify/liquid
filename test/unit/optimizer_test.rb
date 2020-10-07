# frozen_string_literal: true

require 'test_helper'

class OptimizerUnitTest < Minitest::Test
  include Liquid

  def test_combines_append_filters
    optimizer = Optimizer.new
    var = Variable.new('hello | append: "a" | append: b', ParseContext.new)
    var = optimizer.optimize(var)
    assert_equal([
      ['append_all', ["a", VariableLookup.new("b")]]
    ], var.filters)
  end
end
