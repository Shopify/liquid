module Liquid
  class Document < Block
    # we don't need markup to open this block
    def initialize(tokens)
      parse(tokens)
    end

    # There isn't a real delimiter
    def block_delimiter
      []
    end

    # Document blocks don't need to be terminated since they are not actually opened
    def assert_missing_delimitation!
    end

    def render(context)
      output = super
      if context.replacements.size == 0
        output
      else
        re = Regexp.new(context.replacements.keys.map{ |x| Regexp.escape(x) }.join("|"))
        output.gsub(re, context.replacements)
      end
    end
  end
end
