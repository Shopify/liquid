module Liquid
  class PartialCache
    def self.load(template_name, context:, parse_context:)
      cached_partials = (context.registers[:cached_partials] ||= {})
      cached = cached_partials[template_name]
      return cached if cached

      file_system = (context.registers[:file_system] ||= Liquid::Template.file_system)
      source = file_system.read_template_file(template_name)
      parse_context.partial = true

      partial = Liquid::Template.parse(source, parse_context)
      cached_partials[template_name] = partial
    ensure
      parse_context.partial = false
    end
  end
end
