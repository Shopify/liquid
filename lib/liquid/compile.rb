# frozen_string_literal: true

require 'pry-byebug'

module Liquid
  module CompileBlockBody
    def parse(*)
      super

      ruby = +"->(__context, __output, __nodes) {\n"
      compile(ruby)
      ruby << "\n}"

      nodes = nodelist.each_with_object({}) do |node, hash|
        hash[node.object_id] = node
      end

      @instructions = RubyVM::InstructionSequence
          .compile(ruby)
          .eval
    end

    def render_to_output_buffer(context, output)
      @instructions.call(context, output, nodes)
      output
    end

    def compile(ruby)
      ruby << "__context.resource_limits.increment_render_score(#{nodelist.length})\n"
      ruby << "catch(:__interrupt) do\n"
      nodelist.each do |node|
        if node.instance_of?(String)
          ruby << "__output << #{node.inspect}\n"
        else
          ruby << "begin\n"
          if node.line_number.is_a?(Integer)
            ruby << "__line_number = #{node.line_number}\n"
          else
            ruby << "__line_number = nil\n"
          end
          ruby << "__is_blank = #{!node.instance_of?(Variable) && node.blank?}\n"
          ruby << "__node = __nodes[#{node.object_id}]\n"
          if node.respond_to?(:compile)
            node.compile(ruby)
          else
            ruby << "__node.render_to_output_buffer(__context, __output)\n"
          end
          ruby << <<~RUBY
            rescue => __exc
              case __exc
              when Liquid::MemoryError
                raise
              when Liquid::UndefinedVariable, Liquid::UndefinedDropMethod, Liquid::UndefinedFilter
                __context.handle_error(__exc, __line_number)
              else
                __error_message = __context.handle_error(__exc, __line_number)
                unless __is_blank
                  __output << __error_message
                end
              end
            end

            throw :__interrupt if __context.interrupt?
          RUBY
        end
        ruby << "__context.resource_limits.increment_write_score(__output)\n"
      end
      ruby << "end\n"
    end
  end

  class BlockBody
    include CompileBlockBody
  end
end
