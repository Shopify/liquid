require 'yaml'
require 'json'
require 'liquid'

module Liquid
  class ASTToPortableJSON
    def self.dump(ast)
      yaml = YAML.dump(ast)
      yaml.gsub!(/---.*/, '')
      yaml.gsub!(/!ruby\/object:(.+)\n(\s+)/, "\n\\2class_name: \\1\n\\2")

      bare_hash_ast = YAML.load(yaml)
      delete_parse_context(bare_hash_ast)
      JSON.pretty_generate(bare_hash_ast)
    end

    def self.delete_parse_context(bare_hash_ast)
      if bare_hash_ast.is_a?(Array)
        bare_hash_ast.each { |v| delete_parse_context(v) }
      elsif bare_hash_ast.is_a?(Hash)
        bare_hash_ast.delete('parse_context')
        bare_hash_ast.each { |k, v| delete_parse_context(v) }
      end
    end
  end
end

