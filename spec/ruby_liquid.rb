# frozen_string_literal: true

# Liquid Spec Adapter for Shopify/liquid (Ruby reference implementation)
#
# Run with: bundle exec liquid-spec run spec/ruby_liquid.rb

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
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
LiquidSpec.render do |template, ctx|
  static_registers = ctx.registers
  registers = Liquid::Registers.new(static_registers)

  context = Liquid::Context.build(
    static_environments: ctx.environment,
    registers: registers,
    rethrow_errors: ctx.rethrow_errors?,
  )

  context.exception_renderer = ctx.exception_renderer if ctx.exception_renderer

  template.render(context)
end
