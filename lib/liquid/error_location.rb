module Liquid
  ErrorLocation = Struct.new(:template_name, :line_number) do
    def self.line_number_from_token(token)
      token.respond_to?(:line_number) ? token.line_number : nil
    end

    def self.from_token(template_name, token)
      new(template_name, line_number_from_token(token))
    end
  end
end
