# frozen_string_literal: true

require 'test_helper'

class VariableLookupUnitTest < Minitest::Test
  include Liquid

  def test_variable_lookup_parsing
    lookup = parse_variable_lookup('a.b.c')
    assert_equal('a', lookup.name)
    assert_equal(['b', 'c'], lookup.lookups)

    lookup = parse_variable_lookup('a[b]')
    assert_equal('a', lookup.name)
    assert_equal([parse_variable_lookup('b')], lookup.lookups)
  end

  def test_to_s
    lookup = parse_variable_lookup('a.b.c')
    assert_equal('a.b.c', lookup.to_s)

    lookup = parse_variable_lookup('a[b.c].d')
    assert_equal('a[b.c].d', lookup.to_s)
  end

  private

  def parse_variable_lookup(markup)
    if Liquid::Template.error_mode == :strict
      p = Liquid::Parser.new(markup)
      VariableLookup.strict_parse(p)
    else
      VariableLookup.lax_parse(markup)
    end
  end
end
