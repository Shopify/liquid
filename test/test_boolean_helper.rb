#!/usr/bin/env ruby
# frozen_string_literal: true

module Minitest
  module Assertions
    include Liquid
    def assert_with_lax_parsing(template, expected_output, context = {})
      prev_error_mode = Liquid::Environment.default.error_mode
      Liquid::Environment.default.error_mode = :lax

      begin
        actual_output = Liquid::Template.parse(template).render(context)
      rescue StandardError => e
        actual_output = e.message
      ensure
        Liquid::Environment.default.error_mode = prev_error_mode
      end

      assert_equal(expected_output.strip, actual_output.strip)
    end

    def assert_parity(liquid_expression, expected_result, args = {})
      assert_condition(liquid_expression, expected_result, args)
      assert_expression(liquid_expression, expected_result, args)
    end

    def assert_expression(liquid_expression, expected_result, args = {})
      assert_parity_scenario(:expression, "{{ #{liquid_expression} }}", expected_result, args)
    end

    def assert_condition(liquid_condition, expected_result, args = {})
      assert_parity_scenario(:condition, "{% if #{liquid_condition} %}true{% else %}false{% endif %}", expected_result, args)
    end

    def assert_parity_scenario(kind, template, exp_output, args = {})
      act_output = Liquid::Template.parse(template).render(args)

      assert_equal(exp_output, act_output, <<~ERROR_MESSAGE)
        #{kind.to_s.capitalize} template failure:
        ---
        #{template}
        ---
        args: #{args.inspect}
      ERROR_MESSAGE
    end
  end
end

class LinkDrop < Liquid::Drop
  attr_accessor :levels, :links, :title, :type, :url

  def initialize(levels: nil, links: nil, title: nil, type: nil, url: nil)
    super()

    @levels = levels
    @links = links
    @title = title
    @type = type
    @url = url
  end
end
