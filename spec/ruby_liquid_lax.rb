# frozen_string_literal: true

# Liquid Spec Adapter for Shopify/liquid with lax parsing mode
#
# Run with: bundle exec liquid-spec run spec/ruby_liquid_lax.rb

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'liquid'
require_relative 'support/liquid_spec_adapter_helper'

LiquidSpec.configure do |config|
  config.missing_features = [
    :activesupport,
    :shopify_filters,
    :shopify_includes,
    :shopify_blank,
    :shopify_error_handling,
    :shopify_error_format,
    :shopify_string_access,
  ]
end

# Compile a template string into a Liquid::Template
LiquidSpec.compile do |ctx, source, options|
  # Default to lax mode while still honoring specs that explicitly set error_mode.
  options = { error_mode: :lax }.merge(options)
  ctx[:template] = Liquid::Template.parse(source, **options)
end

# Render a compiled template with the given context
LiquidSpec.render do |ctx, assigns, options|
  registers = Liquid::Registers.new(options[:registers] || {})

  context = Liquid::Context.build(
    static_environments: assigns,
    registers: registers,
    rethrow_errors: options[:strict_errors],
    resource_limits: LiquidSpecAdapterHelper.resource_limits(options),
  )

  context.exception_renderer = options[:exception_renderer] if options[:exception_renderer]

  LiquidSpecAdapterHelper.with_frozen_time do
    ctx[:template].render(context)
  end
end
