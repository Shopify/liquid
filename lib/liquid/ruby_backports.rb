module Liquid
  module RubyBackports
    Liquid.private_constant :RubyBackports

    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.4')
      refine String do
        def match?(regexp)
          !!(self =~ regexp)
        end
      end
    end
  end
end
