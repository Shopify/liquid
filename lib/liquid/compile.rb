# frozen_string_literal: true

require 'pry-byebug'
require 'set'

module Liquid
  class Compiler
    def initialize
      @ruby = +""
      @nodes = {}
      @declared = Set.new(['__l_product'])
    end

    def <<(line)
      @ruby << line
    end

    def var_name(name)
      "__l_#{name}"
    end

    def declare(name)
      @declared << name
    end

    def declared?(name)
      @declared.member?(name)
    end

    def to_proc
      show_ruby = ENV["SHOW_RUBY"] && ENV["SHOW_RUBY"].to_i || 0
      STDERR.puts @ruby if show_ruby >= 1
      res = RubyVM::InstructionSequence.compile(<<~RUBY).eval.call(@nodes)
      # frozen_string_literal: true
      ->(__nodes) {
        ->(__context, __output, __l_product) {
          __assigns = __context.scopes.last
          #{@ruby}
          __output
        }
      }
      RUBY

      STDERR.puts RubyVM::InstructionSequence.disasm(res) if show_ruby >= 2
      res
    end

    def compile_expr(node)
      if node.respond_to?(:compile_expr)
        node.compile_expr(self)
      else
        case node
        when Range # returned by RangeLookup when range contains only literals
          node.inspect
        when Integer, Float, nil, true, false, String
          node.inspect
        else
          raise ArgumentError, "cannot compile node #{node.inspect}"
        end
      end
    end

    def output(node)
      compiled = compile_expr(node)
      self << if compiled.is_a?(String)
        "__output << #{compiled}\n"
      else
        "__output << #{compiled}.to_s\n"
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
            self << "__nodes[#{node.object_id}].render_to_output_buffer(__context, __output) # #{node.inspect} \n"
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
      @compiled.call(context, output, context.environments[0][:product])
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
      # HACK
      if @name == "forloop" && @lookups == ["first"]
        return "forloop_first"
      end

      var_name = compiler.var_name(@name)
      root = if compiler.declared?(var_name)
        var_name
      else
        "__scope[#{@name.inspect}]"
      end

      @lookups.reduce(root) do |prev, lookup|
        "#{prev}[:#{lookup}]"
      end
    end
  end

  class Variable
    FILTERS = {
      "modulo" => ->(compiler, expr, args, kwargs) {
        "(#{expr} % #{args[0]})"
      },
      "product_img_url" => ->(compiler, expr, args, kwargs) {
        style = args.fetch(0, 'small')

        rest = case style
        when 'original'
          "\"/files/shops/random_number/\#{url}\""
        when 'grande', 'large', 'medium', 'compact', 'small', 'thumb', 'icon'
          "\"/files/shops/random_number/products/\#{$1}_#{style}.\#{$2}\""
        else
          "raise ArgumentError, 'valid parameters for filter \"size\" are: original, grande, large, medium, compact, small, thumb and icon '"
        end

        <<~RUBY.strip
        (begin
          if #{expr} =~ %r{\\Aproducts/([\\w\\-\\_]+)\\.(\\w{2,4})}
            #{rest}
          else
            raise ArgumentError, 'filter \"size\" can only be called on product images'
          end
        end)
        RUBY
      },
      "escape" => ->(compiler, expr, args, kwargs) {
        "(_t = #{expr}; CGI.escapeHTML(_t) if _t)"
      },
      "money" => ->(compiler, expr, args, kwargs) {
        "(_m = #{expr}; _m.nil? ? '' : \"$ \#{(_m / 100.0).round(2)}\")"
      },
    }

    def compile(compiler)
      if const?
        compiler.output(name)
      else
        compiler.catch_errors(@line_number, show_message: true) do
          compiler.output(self)
        end
      end
    end

    def const?
      @filters.empty? && !name.respond_to?(:compile_expr)
    end

    def compile_expr(compiler)
      @filters.reduce(compiler.compile_expr(name)) do |expr, (name, args, kwargs)|
        if FILTERS.key?(name)
          FILTERS[name].call(compiler, expr, args, kwargs)
        else
          expr
        end
      end
    end
  end

  class Echo
    def compile(compiler)
      compiler.compile(variable)
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

      item_var = compiler.var_name(variable_name)
      compiler << <<~RUBY
        forloop_first = true
        for #{item_var} in collection
      RUBY
      compiler.declare(item_var)
      compiler.compile(@for_block)
      compiler << <<~RUBY
          forloop_first = false
        end
      RUBY

    end
  end

  class If
    def compile(compiler)
      compiler << "if #{compiler.compile_expr(blocks[0])}\n"
      compiler.compile(blocks[0].attachment)
      blocks.drop(1).each do |block|
        if block.else?
          compiler << "else\n"
        else
          compiler << "elsif #{block.compile_expr(compiler)}\n"
        end
        compiler.compile(block.attachment)
      end
      compiler << "end\n"
    end
  end

  class Comment
    def compile(_compiler); end
  end

  class Condition
    def compile_expr(compiler)
      if operator
        left_expr = compiler.compile_expr(left)
        right_expr = compiler.compile_expr(right)
        if child_relation
          child_expr = compiler.compile_expr(child_condition)
          expr = "((#{left_expr} #{operator} #{right_expr}) #{child_relation} #{child_expr})"
        else
          expr = "(#{left_expr} #{operator} #{right_expr})"
        end
        expr
      else
        left_expr = compiler.compile_expr(left)
        expr = "#{left_expr}"
      end
    end
  end

  class Assign
    def compile(compiler)
      compiler.declare(compiler.var_name(@to))
      compiler << "#{compiler.var_name(@to)} = #{compiler.compile_expr(@from)}\n"
    end
  end
end
