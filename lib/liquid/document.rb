module Liquid
  class Document < Block
    def self.parse(tokens, options={})
      # we don't need markup to open this block
      super(nil, nil, tokens, options)
    end

    # There isn't a real delimiter
    def block_delimiter
      []
    end

    # Document blocks don't need to be terminated since they are not actually opened
    def assert_missing_delimitation!
    end
  end
end
