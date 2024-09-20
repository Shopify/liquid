# frozen_string_literal: true

module Liquid
  class PartialCache
    def self.load(template_name, context:, parse_context:)
      cached_partials = context.registers[:cached_partials]
      cache_key = "#{template_name}:#{parse_context.error_mode}"
      cached = cached_partials[cache_key]
      return cached if cached

      file_system = context.registers[:file_system]
      source      = file_system.read_template_file(template_name)

      parse_context.partial = true

      template_factory = context.registers[:template_factory]
      template = template_factory.for(template_name)

      begin
        partial = template.parse(source, parse_context)
      rescue Liquid::Error => e
        e.template_name = template&.name || template_name
        raise e
      end

      partial.name ||= template_name

      cached_partials[cache_key] = partial
    ensure
      parse_context.partial = false
    end
  end
end
