# frozen_string_literal: true

# Liquid Spec Adapter for Shopify/liquid with ActiveSupport loaded
#
# Run with: bundle exec liquid-spec run spec/ruby_liquid_with_active_support.rb

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'active_support/all'
require 'liquid'

LiquidSpec.configure do |config|
  # Run core Liquid specs
  config.features = [:core]
end

# Compile a template string into a Liquid::Template
LiquidSpec.compile do |source, options|
  Liquid::Template.parse(source, **options)
end

# Render a compiled template with the given context
# @param template [Liquid::Template] compiled template
# @param assigns [Hash] environment variables
# @param options [Hash] :registers, :strict_errors, :exception_renderer
LiquidSpec.render do |template, assigns, options|
  registers = Liquid::Registers.new(options[:registers] || {})

  context = Liquid::Context.build(
    static_environments: assigns,
    registers: registers,
    rethrow_errors: options[:strict_errors],
  )

  context.exception_renderer = options[:exception_renderer] if options[:exception_renderer]

  template.render(context)
end
