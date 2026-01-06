# frozen_string_literal: true

# Liquid Spec Adapter for Shopify/liquid with YJIT + strict mode + ActiveSupport
#
# Run with: bundle exec liquid-spec run spec/ruby_liquid_yjit.rb

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

# Enable YJIT if available
if defined?(RubyVM::YJIT) && RubyVM::YJIT.respond_to?(:enable)
  RubyVM::YJIT.enable
end

require 'active_support/all'
require 'liquid'

LiquidSpec.configure do |config|
  config.features = [:core, :activesupport]
end

# Compile a template string into a Liquid::Template
LiquidSpec.compile do |ctx, source, options|
  # Force strict mode
  options = { error_mode: :strict }.merge(options)
  Liquid::Template.parse(source, **options)
end

# Render a compiled template with the given context
LiquidSpec.render do |ctx, template, assigns, options|
  registers = Liquid::Registers.new(options[:registers] || {})

  context = Liquid::Context.build(
    static_environments: assigns,
    registers: registers,
    rethrow_errors: options[:strict_errors],
  )

  context.exception_renderer = options[:exception_renderer] if options[:exception_renderer]

  template.render(context)
end
