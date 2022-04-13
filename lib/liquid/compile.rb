# frozen_string_literal: true

require 'pry-byebug'

module Liquid
  class Compiler
    def initialize
      @ruby = +""
      @nodes = {}
    end

    def <<(line)
      @ruby << line
    end

    def var_name(name)
      "__l_#{name}"
    end

    def to_proc
      puts @ruby if ENV['SHOW_RUBY'] == '1'
      RubyVM::InstructionSequence.compile(<<~RUBY).eval.call(@nodes)
      ->(__nodes) {
        ->(__context, __output) {
          #{@ruby}
          __output
        }
      }
      RUBY
    end

    # Compiles any thing that can be returned by Expression/QuotedFragment
    def compile_expr(node)
      case node
      when Liquid::VariableLookup
        @nodes[node.object_id] = node
        node.compile_expr(self)
      when Liquid::RangeLookup
        @nodes[node.object_id] = node
        node.compile_expr(self)
      when Range # returned by RangeLookup when range contains only literals
        node.inspect
      when Integer, Float, nil, true, false, ''
        node.inspect
      else
        raise ArgumentError, "cannot compile node #{node.inspect}"
      end
    end

    def fallback_evaluate_expr(node)
      "__nodes[#{node.object_id}].evaluate(__context)"
    end

    def to_integer_expr(var_name)
      <<~RUBY.strip
      (begin
        if #{var_name}.is_a?(Integer)
          #{var_name}
        else
          begin
            Integer(#{var_name}.to_s)
          rescue ::ArgumentError
            raise Liquid::ArgumentError, "invalid integer"
          end
        end
      end)
      RUBY
    end

    def slice_collection_expr(collection_name, from_name, to_name)
      <<~RUBY.strip
      (begin
        if (#{from_name} != 0 || !#{to_name}.nil?) && #{collection_name}.respond_to?(:load_slice)
          #{collection_name}.load_slice(#{from_name}, #{to_name})
        else
          segments = []
          index = 0
          if #{collection_name}.is_a?(String)
            #{collection_name}.empty? ? [] : [collection]
          elsif !#{collection_name}.respond_to?(:each)
            []
          else
            #{collection_name}.each do |item|
              if #{to_name} && #{to_name} <= index
                break
              end

              if #{from_name} && #{from_name} <= index
                segments << item
              end

              index += 1
            end

            segments
          end
        end
      end)
      RUBY
    end

    def compile(node)
      if node.instance_of?(String)
        self << "__output << #{node.inspect}\n"
      else
        @nodes[node.object_id] = node
        if node.respond_to?(:compile)
          node.compile(self)
        else
          line_number = if node.respond_to?(:line_number) && node.line_number.is_a?(Integer)
            node.line_number
          else
            nil
          end
          catch_errors(line_number, show_message: !node.blank?) do
            self << "__nodes[#{node.object_id}].render_to_output_buffer(__context, __output)\n"
          end
        end
      end
    end

    def catch_errors(line_number, show_message: true)
      self << "begin\n"
      yield
      self << <<~RUBY
        rescue => __exc
          case __exc
          when Liquid::MemoryError
            raise
          when Liquid::UndefinedVariable, Liquid::UndefinedDropMethod, Liquid::UndefinedFilter
            __context.handle_error(__exc, #{line_number.inspect})
          else
            __error_message = __context.handle_error(__exc, #{line_number.inspect})
      RUBY
      self << "__output << __error_message\n" if show_message
      self << "end\nend\n"
    end

  end

  class BlockBody
    def render_to_output_buffer(context, output)
      raise "Tried to render uncompiled block" unless @compiled
      @compiled.call(context, output)
    end

    def compile_top_level
      compiler = Compiler.new
      compile(compiler)
      @compiled = compiler.to_proc
    end

    def compile(compiler)
      nodelist.each { |node| compiler.compile(node) }
    end
  end

  class Document
    def parse(tokenizer, parse_context)
      while parse_body(tokenizer)
      end
      @body.compile_top_level
      @body.freeze
    rescue SyntaxError => e
      e.line_number ||= parse_context.line_number
      raise
    end
  end

  class VariableLookup
    def compile_expr(compiler)
      compiler.var_name(@name)
    end
  end

  class Variable
    def compile(compiler)
      compiler.catch_errors(@line_number, show_message: true) do
        compiler << "__output << #{@name.compile_expr(compiler)}.to_s\n"
      end
    end
  end

  class For
    def compile(compiler)
      compiler << "collection = #{compiler.compile_expr(@collection_name)}\n"
    
      unless @from.nil?
        compiler << <<~RUBY
          from_value = #{compiler.compile_expr(@from)}
          from = if from_value.nil?
            0
          else
            #{compiler.to_integer_expr(:from_value)}
          end

          limit_value = #{compiler.compile_expr(@limit)}
          to = if limit_value.nil?
            nil
          else
            #{compiler.to_integer_expr(:limit_value)} + from
          end

          collection = #{compiler.slice_collection_expr(:collection, :from, :to)}
          #{@reversed ? "segment.reverse!" : "" }
        RUBY
      end

      compiler << <<~RUBY
        collection.each do |#{compiler.var_name(variable_name)}|
      RUBY
      compiler.compile(@for_block)
      compiler << "end\n"
    end
  end
end
