# frozen_string_literal: true

require 'test_helper'

class FilterKwargTest < Minitest::Test
  module KwargFilter
    def html_tag(_tag, attributes)
      attributes
        .map { |key, value| "#{key}='#{value}'" }
        .join(' ')
    end
  end

  include Liquid

  def test_can_parse_data_kwargs
    with_global_filter(KwargFilter) do
      assert_equal(
        "data-src='src' data-widths='100, 200'",
        Template.parse("{{ 'img' | html_tag: data-src: 'src', data-widths: '100, 200' }}").render(nil, nil)
      )
    end
  end
end
