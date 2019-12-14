# frozen_string_literal: true

module Liquid
  class PartialCache
    def self.load(template_name, context:, parse_context:, caller:)
      cached_partials = (context.registers[:cached_partials] ||= {})
      cached = cached_partials["#{caller}:#{template_name}"]
      return cached if cached

      file_system = (context.registers[:file_system] ||= Liquid::Template.file_system)
      parse_context.partial = true

      source = if file_system.respond_to?(:read_template_file_with_options)
        file_system.read_template_file_with_options(template_name, caller: caller)
      else
        file_system.read_template_file(template_name)
      end

      partial = Liquid::Template.parse(source, parse_context)
      cached_partials["#{caller}:#{template_name}"] = partial
    ensure
      parse_context.partial = false
    end
  end
end
