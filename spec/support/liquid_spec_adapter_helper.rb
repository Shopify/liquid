# frozen_string_literal: true

module LiquidSpecAdapterHelper
  extend self

  def resource_limits(render_options)
    return unless render_options[:resource_limits]

    Liquid::ResourceLimits.new({}).tap do |limits|
      render_options[:resource_limits].each do |key, value|
        limits.public_send(:"#{key}=", value)
      end
    end
  end

  def with_frozen_time(&block)
    original_tz = ENV['TZ']
    ENV['TZ'] = 'UTC'

    Liquid::Spec::TimeFreezer.freeze(Liquid::Spec::AdapterRunner::TEST_TIME, &block)
  ensure
    ENV['TZ'] = original_tz
  end
end
