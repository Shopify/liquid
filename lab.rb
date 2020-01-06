require 'liquid'
require 'ap'
require 'pry'

AwesomePrint.defaults = {
  raw: true
}

def yell!(message)
  system("toilet --gay #{message}")
end

def derp(message, expr)
  yell! message
  ap expr
  exit
end

class SuperfluidError < Exception
end

class Output
  attr_reader :string

  def initialize(initial_indent)
    @string = ''.dup
    @indent_level = initial_indent
    @indent_str = " " * initial_indent * 2
  end

  def <<(line)
    @string << @indent_str << line << "\n"
  end

  def indent
    @indent_level += 1
    @indent_str = " " * @indent_level * 2
    yield
    @indent_level -= 1
    @indent_str = " " * @indent_level * 2
  end
end

class Compiler
  class << self
    def compile(template)
      compiler = new
      compiler.compile(template)
      compiler.ruby
    end
  end

  def initialize
    @output = Output.new(2)
  end

  def ruby
    [
      header,
      @output.string,
      trailer
    ].join("\n")
  end

  def compile(node)
    case node
    when Liquid::Document, Liquid::BlockBody
      node.nodelist.collect(&method(:compile))
    when Liquid::Variable
      compile_variable(node)
    when Liquid::For
      compile_for(node)
    when Liquid::If
      compile_if(node)
    when Liquid::Template
      compile(node.root)
    when Liquid::Assign
      compile_assign(node)
    when Liquid::Case
      compile_case(node)
    when Liquid::Capture
      compile_capture(node)
    when String
      compile_echo_literal(node)
    when Liquid::Break
      line "break"
    else
      yell! "Weird node"
      ap node
      exit
    end
  end

  def header
    <<~RUBY
    class NilUndefinedMethod
      def method_missing(*)
        nil
      end

      def run(liquid_out, strainer)
    RUBY
  end

  def trailer
    <<~RUBY
        end
      end
      NilUndefinedMethod.new.method(:run)
    RUBY
  end

  def compile_for(node)
    variable_name = node.variable_name

    collection_name = node.collection_name
    iter_target_expr = case collection_name
                       when Liquid::VariableLookup
                         var(collection_name.name)
                       when Range
                         collection_name
                       when Liquid::RangeLookup
                         start_expr = make_variable_expr(collection_name.start_obj)
                         end_expr = make_variable_expr(collection_name.end_obj)
                         "#{start_expr}..#{end_expr}"
                       else
                         derp "Weird iter!", collection_name
                       end

    line "(#{iter_target_expr}).each do |#{var(variable_name)}|"
      indent { compile(node.for_block) }
    line "end"
  end

  def compile_if(node)
    condition = node.blocks.first
    line "if #{make_condition_expr(condition)}"
      indent { condition.attachment.nodelist.each(&method(:compile)) }
    line "end"
  end

  def compile_capture(node)
    line "#{var(node.to)} = lambda do |; liquid_out|"
    indent do
      line "liquid_out = StringIO.new"
      node.nodelist.each(&method(:compile))
      line "liquid_out.string"
    end
    line "end.call"
  end

  def make_condition_expr(node)
    make_variable_expr(node)
    if node.operator
      left = make_variable_expr(node.left)
      right = make_variable_expr(node.right)
      "#{left} #{node.operator} #{right}"
    else
      make_variable_expr(node.left)
    end
  end

  # TEST CASES:
  #   - else
  #   - only an else, no cases
  #   - top value is a literal
  #   - multiple elses
  #   - else not at the end
  def compile_case(node)
    line 'if false' # HACK
    else_nodes, if_nodes = node.blocks.partition { |n| n.is_a?(Liquid::ElseCondition) }
    raise SuperfluidError, 'Too many else nodes' if else_nodes.count > 1
    else_node = else_nodes.first

    if_nodes.each do |condition|
      left = make_variable_expr(condition.left)
      right = make_variable_expr(condition.right)
      line "elsif #{left} #{condition.operator} #{right}"
      indent { condition.attachment.nodelist.each(&method(:compile)) }
    end

    if else_node
      line "else"
      indent { else_node.attachment.nodelist.each(&method(:compile)) }
    end

    line "end"
  end

  def compile_echo_literal(node)
    echo node.inspect
  end

  def compile_variable(variable)
    echo make_variable_expr(variable)
  end

  def compile_assign(node)
    from_expr = case node.from
    when Liquid::Variable
      make_variable_expr(node.from)
    else
      derp "Weird assign", node
    end

    line "#{var(node.to)} = #{from_expr}"
  end

  def make_variable_expr(variable)
    case variable
    when Liquid::Variable
      base_expression = case variable.name
      when Integer
        variable.name
      when String
        variable.name.inspect
      when TrueClass, FalseClass
        variable.name
      when Liquid::VariableLookup
        result = var(variable.name.name)
        variable.name.lookups.each do |lookup|
          result << "[#{make_variable_expr(lookup)}]"
        end
        result
      else
        derp "Bad var name", variable.name
      end
      variable.filters.inject(base_expression) do |inner, filter|
        filter_name = filter.first
        args = filter.last.map(&method(:make_variable_expr))
        "strainer.invoke(#{filter_name.inspect}, #{inner}, *[#{args.join(', ')}])"
      end
    when Liquid::VariableLookup
      var(variable.name)
    else
      variable.inspect
    end
  end

  private

  def line(string)
    output << string
  end

  def echo(string)
    output << "liquid_out.write(#{string})"
  end

  def indent(&block)
    output.indent(&block)
  end

  def var(name)
    "__liquid_#{name}"
  end

  attr_reader :output
end

source = <<~LIQUID
{% capture newline %}
{% endcapture %}
{% assign constants = "0 1000 1 " | split: " "  %}{% assign bytecode = "c/0 s/0 v/0 c/1 < ! j/8 v/0 e v/0 c/2 + s/0 g/-11 r " %}{% assign ops = bytecode | split: " " %}{% assign broken = false %}{% assign data_stack = "__BASE__" %}{% assign data_stack_top = 0 %}{% assign data_stack_last_len = 0 %}{% assign var_stack = "__BASE__" %}{% assign var_stack_top = 0 %}{% assign var_stack_last_len = 0 %}{% assign return_stack = "__BASE__" %}{% assign return_stack_top = 0 %}{% assign return_stack_last_len = 0 %}{% assign pc = 0 %}{% assign cycle_count = 0 %}{% assign output = "" %}{% assign var0 = "" %}{% assign var1 = "" %}{% assign var2 = "" %}{% assign var3 = "" %}{% assign var4 = "" %}{% assign var5 = "" %}{% assign var6 = "" %}{% assign var7 = "" %}{% assign var8 = "" %}{% assign var9 = "" %}{% assign var10 = "" %}{% assign var11 = "" %}{% assign var12 = "" %}{% assign var13 = "" %}{% assign var14 = "" %}{% assign var15 = "" %}{% assign var16 = "" %}{% assign var17 = "" %}{% assign var18 = "" %}{% assign var19 = "" %}{% assign var20 = "" %}{% assign var21 = "" %}{% assign var22 = "" %}{% assign var23 = "" %}{% assign var24 = "" %}{% assign var25 = "" %}{% assign var26 = "" %}{% assign var27 = "" %}{% assign var28 = "" %}{% assign var29 = "" %}{% assign var30 = "" %}{% assign var31 = "" %}{% assign var32 = "" %}{% assign var33 = "" %}{% assign var34 = "" %}{% assign var35 = "" %}{% assign var36 = "" %}{% assign var37 = "" %}{% assign var38 = "" %}{% assign var39 = "" %}{% assign var40 = "" %}{% assign var41 = "" %}{% assign var42 = "" %}{% assign var43 = "" %}{% assign var44 = "" %}{% assign var45 = "" %}{% assign var46 = "" %}{% assign var47 = "" %}{% assign var48 = "" %}{% assign var49 = "" %}{% assign var50 = "" %}{% assign var51 = "" %}{% assign var52 = "" %}{% assign var53 = "" %}{% assign var54 = "" %}{% assign var55 = "" %}{% assign var56 = "" %}{% assign var57 = "" %}{% assign var58 = "" %}{% assign var59 = "" %}{% assign var60 = "" %}{% assign var61 = "" %}{% assign var62 = "" %}{% assign var63 = "" %}{% assign var64 = "" %}{% assign var65 = "" %}{% assign var66 = "" %}{% assign var67 = "" %}{% assign var68 = "" %}{% assign var69 = "" %}{% assign var70 = "" %}{% assign var71 = "" %}{% assign var72 = "" %}{% assign var73 = "" %}{% assign var74 = "" %}{% assign var75 = "" %}{% assign var76 = "" %}{% assign var77 = "" %}{% assign var78 = "" %}{% assign var79 = "" %}{% assign var80 = "" %}{% assign var81 = "" %}{% assign var82 = "" %}{% assign var83 = "" %}{% assign var84 = "" %}{% assign var85 = "" %}{% assign var86 = "" %}{% assign var87 = "" %}{% assign var88 = "" %}{% assign var89 = "" %}{% assign var90 = "" %}{% assign var91 = "" %}{% assign var92 = "" %}{% assign var93 = "" %}{% assign var94 = "" %}{% assign var95 = "" %}{% assign var96 = "" %}{% assign var97 = "" %}{% assign var98 = "" %}{% assign var99 = "" %}{% for _tick in (1..1000) %}{% for _tick in (1..1000) %}{% for _tick in (1..1000) %}{% assign cycle_count = cycle_count | plus: 1 %}{% assign op_str = ops[pc] %}{% assign op = op_str | split: "/" %}{% assign op_type = op[0] %}{% assign next_pc = pc | plus: 1 %}{% case op_type %}{% when "c" %}{% assign constant_index = op[1] | plus: 0 %}{% assign constant_value = constants[constant_index] %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: constant_value %}{% when "+" %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign result = first | plus: second %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: result %}{% when "-" %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign result = first | minus: second %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: result %}{% when "%" %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign result = first | modulo: second %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: result %}{% when ">" %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign first = first | plus: 0 %}{% assign second = second | plus: 0 %}{% if second > first  %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: 1 %}{% else %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: 0 %}{% endif %}{% when "<" %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign first = first | plus: 0 %}{% assign second = second | plus: 0 %}Comparing {{ first }} < {{ second }}{% if second < first  %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: 1 %}{% else %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: 0 %}{% endif %}{% when "|" %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign first = first | plus: 0 %}{% assign second = second | plus: 0 %}{% if first == 1 or second == 1 %}PUSH(data_stack, 1){% else %}PUSH(data_stack, 0){% endif %}{% when "&" %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign first = first | plus: 0 %}{% assign second = second | plus: 0 %}{% if first == 1 and second == 1 %}PUSH(data_stack, 1){% else %}PUSH(data_stack, 0){% endif %}{% when "!" %}{% assign data_stack_array = data_stack | split: " " %}{% assign top = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign top = top | plus: 0 %}{% if top == 1 %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: 0 %}{% else %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: 1 %}{% endif %}{% when "*" %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign result = first | times: second %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: result %}{% when "÷" %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign result = first | divided_by: second %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: result %}{% when "e" %}{% assign data_stack_array = data_stack | split: " " %}{% assign popped = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign output = output | append: popped | append: newline %}{% when "=" %}{% assign data_stack_array = data_stack | split: " " %}{% assign first = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign data_stack_array = data_stack | split: " " %}{% assign second = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign result = 0 %}{% if first == second %}{% assign result = 1 %}{% endif %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: result %}{% when "j" %}{% assign target = op[1] %}{% assign target = target | plus: 0 %}{% assign data_stack_array = data_stack | split: " " %}{% assign condition = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% assign condition = condition | plus: 0 %}{% if condition == 1 %}{% assign next_pc = pc | plus: target %}{% endif %}{% when "g" %}{% assign target = op[1] %}{% assign target = target | plus: 0 %}{% assign next_pc = pc | plus: target %}{% when "k" %}{% assign target = op[1] %}{% assign target = target | plus: 0 %}{% assign stack_frame = var0 | append: '/' | append: var1 | append: '/' | append: var2 | append: '/' | append: var3 | append: '/' | append: var4 | append: '/' | append: var5 | append: '/' | append: var6 | append: '/' | append: var7 | append: '/' | append: var8 | append: '/' | append: var9 | append: '/' | append: var10 | append: '/' | append: var11 | append: '/' | append: var12 | append: '/' | append: var13 | append: '/' | append: var14 | append: '/' | append: var15 | append: '/' | append: var16 | append: '/' | append: var17 | append: '/' | append: var18 | append: '/' | append: var19 | append: '/' | append: var20 | append: '/' | append: var21 | append: '/' | append: var22 | append: '/' | append: var23 | append: '/' | append: var24 | append: '/' | append: var25 | append: '/' | append: var26 | append: '/' | append: var27 | append: '/' | append: var28 | append: '/' | append: var29 | append: '/' | append: var30 | append: '/' | append: var31 | append: '/' | append: var32 | append: '/' | append: var33 | append: '/' | append: var34 | append: '/' | append: var35 | append: '/' | append: var36 | append: '/' | append: var37 | append: '/' | append: var38 | append: '/' | append: var39 | append: '/' | append: var40 | append: '/' | append: var41 | append: '/' | append: var42 | append: '/' | append: var43 | append: '/' | append: var44 | append: '/' | append: var45 | append: '/' | append: var46 | append: '/' | append: var47 | append: '/' | append: var48 | append: '/' | append: var49 | append: '/' | append: var50 | append: '/' | append: var51 | append: '/' | append: var52 | append: '/' | append: var53 | append: '/' | append: var54 | append: '/' | append: var55 | append: '/' | append: var56 | append: '/' | append: var57 | append: '/' | append: var58 | append: '/' | append: var59 | append: '/' | append: var60 | append: '/' | append: var61 | append: '/' | append: var62 | append: '/' | append: var63 | append: '/' | append: var64 | append: '/' | append: var65 | append: '/' | append: var66 | append: '/' | append: var67 | append: '/' | append: var68 | append: '/' | append: var69 | append: '/' | append: var70 | append: '/' | append: var71 | append: '/' | append: var72 | append: '/' | append: var73 | append: '/' | append: var74 | append: '/' | append: var75 | append: '/' | append: var76 | append: '/' | append: var77 | append: '/' | append: var78 | append: '/' | append: var79 | append: '/' | append: var80 | append: '/' | append: var81 | append: '/' | append: var82 | append: '/' | append: var83 | append: '/' | append: var84 | append: '/' | append: var85 | append: '/' | append: var86 | append: '/' | append: var87 | append: '/' | append: var88 | append: '/' | append: var89 | append: '/' | append: var90 | append: '/' | append: var91 | append: '/' | append: var92 | append: '/' | append: var93 | append: '/' | append: var94 | append: '/' | append: var95 | append: '/' | append: var96 | append: '/' | append: var97 | append: '/' | append: var98 | append: '/' | append: var99 %}{% assign var_stack_top = var_stack_top | plus: 1 %}{% assign var_stack = var_stack | append: " " | append: stack_frame %}{% assign continue_pc = pc | plus: 1 %}{% assign return_stack_top = return_stack_top | plus: 1 %}{% assign return_stack = return_stack | append: " " | append: continue_pc %}{% assign next_pc = target %}{% when "s" %}{% assign var_num = op[1] %}{% assign var_num = var_num | plus: 0 %}{% assign data_stack_array = data_stack | split: " " %}{% assign new_value = data_stack_array | last %}{% assign data_stack = data_stack | truncatewords: data_stack_top | remove: "..." %}{% assign data_stack_top = data_stack_top | minus: 1 %}{% case var_num %}{% when 0 %}{% assign var0 = new_value %}{% when 1 %}{% assign var1 = new_value %}{% when 2 %}{% assign var2 = new_value %}{% when 3 %}{% assign var3 = new_value %}{% when 4 %}{% assign var4 = new_value %}{% when 5 %}{% assign var5 = new_value %}{% when 6 %}{% assign var6 = new_value %}{% when 7 %}{% assign var7 = new_value %}{% when 8 %}{% assign var8 = new_value %}{% when 9 %}{% assign var9 = new_value %}{% when 10 %}{% assign var10 = new_value %}{% when 11 %}{% assign var11 = new_value %}{% when 12 %}{% assign var12 = new_value %}{% when 13 %}{% assign var13 = new_value %}{% when 14 %}{% assign var14 = new_value %}{% when 15 %}{% assign var15 = new_value %}{% when 16 %}{% assign var16 = new_value %}{% when 17 %}{% assign var17 = new_value %}{% when 18 %}{% assign var18 = new_value %}{% when 19 %}{% assign var19 = new_value %}{% when 20 %}{% assign var20 = new_value %}{% when 21 %}{% assign var21 = new_value %}{% when 22 %}{% assign var22 = new_value %}{% when 23 %}{% assign var23 = new_value %}{% when 24 %}{% assign var24 = new_value %}{% when 25 %}{% assign var25 = new_value %}{% when 26 %}{% assign var26 = new_value %}{% when 27 %}{% assign var27 = new_value %}{% when 28 %}{% assign var28 = new_value %}{% when 29 %}{% assign var29 = new_value %}{% when 30 %}{% assign var30 = new_value %}{% when 31 %}{% assign var31 = new_value %}{% when 32 %}{% assign var32 = new_value %}{% when 33 %}{% assign var33 = new_value %}{% when 34 %}{% assign var34 = new_value %}{% when 35 %}{% assign var35 = new_value %}{% when 36 %}{% assign var36 = new_value %}{% when 37 %}{% assign var37 = new_value %}{% when 38 %}{% assign var38 = new_value %}{% when 39 %}{% assign var39 = new_value %}{% when 40 %}{% assign var40 = new_value %}{% when 41 %}{% assign var41 = new_value %}{% when 42 %}{% assign var42 = new_value %}{% when 43 %}{% assign var43 = new_value %}{% when 44 %}{% assign var44 = new_value %}{% when 45 %}{% assign var45 = new_value %}{% when 46 %}{% assign var46 = new_value %}{% when 47 %}{% assign var47 = new_value %}{% when 48 %}{% assign var48 = new_value %}{% when 49 %}{% assign var49 = new_value %}{% when 50 %}{% assign var50 = new_value %}{% when 51 %}{% assign var51 = new_value %}{% when 52 %}{% assign var52 = new_value %}{% when 53 %}{% assign var53 = new_value %}{% when 54 %}{% assign var54 = new_value %}{% when 55 %}{% assign var55 = new_value %}{% when 56 %}{% assign var56 = new_value %}{% when 57 %}{% assign var57 = new_value %}{% when 58 %}{% assign var58 = new_value %}{% when 59 %}{% assign var59 = new_value %}{% when 60 %}{% assign var60 = new_value %}{% when 61 %}{% assign var61 = new_value %}{% when 62 %}{% assign var62 = new_value %}{% when 63 %}{% assign var63 = new_value %}{% when 64 %}{% assign var64 = new_value %}{% when 65 %}{% assign var65 = new_value %}{% when 66 %}{% assign var66 = new_value %}{% when 67 %}{% assign var67 = new_value %}{% when 68 %}{% assign var68 = new_value %}{% when 69 %}{% assign var69 = new_value %}{% when 70 %}{% assign var70 = new_value %}{% when 71 %}{% assign var71 = new_value %}{% when 72 %}{% assign var72 = new_value %}{% when 73 %}{% assign var73 = new_value %}{% when 74 %}{% assign var74 = new_value %}{% when 75 %}{% assign var75 = new_value %}{% when 76 %}{% assign var76 = new_value %}{% when 77 %}{% assign var77 = new_value %}{% when 78 %}{% assign var78 = new_value %}{% when 79 %}{% assign var79 = new_value %}{% when 80 %}{% assign var80 = new_value %}{% when 81 %}{% assign var81 = new_value %}{% when 82 %}{% assign var82 = new_value %}{% when 83 %}{% assign var83 = new_value %}{% when 84 %}{% assign var84 = new_value %}{% when 85 %}{% assign var85 = new_value %}{% when 86 %}{% assign var86 = new_value %}{% when 87 %}{% assign var87 = new_value %}{% when 88 %}{% assign var88 = new_value %}{% when 89 %}{% assign var89 = new_value %}{% when 90 %}{% assign var90 = new_value %}{% when 91 %}{% assign var91 = new_value %}{% when 92 %}{% assign var92 = new_value %}{% when 93 %}{% assign var93 = new_value %}{% when 94 %}{% assign var94 = new_value %}{% when 95 %}{% assign var95 = new_value %}{% when 96 %}{% assign var96 = new_value %}{% when 97 %}{% assign var97 = new_value %}{% when 98 %}{% assign var98 = new_value %}{% when 99 %}{% assign var99 = new_value %}{% endcase %}{% when "v" %}{% assign var_num = op[1] %}{% assign var_num = var_num | plus: 0 %}{% assign loaded_value = -1337 %}{% case var_num %}{% when 0 %}{% assign loaded_value = var0 %}{% when 1 %}{% assign loaded_value = var1 %}{% when 2 %}{% assign loaded_value = var2 %}{% when 3 %}{% assign loaded_value = var3 %}{% when 4 %}{% assign loaded_value = var4 %}{% when 5 %}{% assign loaded_value = var5 %}{% when 6 %}{% assign loaded_value = var6 %}{% when 7 %}{% assign loaded_value = var7 %}{% when 8 %}{% assign loaded_value = var8 %}{% when 9 %}{% assign loaded_value = var9 %}{% when 10 %}{% assign loaded_value = var10 %}{% when 11 %}{% assign loaded_value = var11 %}{% when 12 %}{% assign loaded_value = var12 %}{% when 13 %}{% assign loaded_value = var13 %}{% when 14 %}{% assign loaded_value = var14 %}{% when 15 %}{% assign loaded_value = var15 %}{% when 16 %}{% assign loaded_value = var16 %}{% when 17 %}{% assign loaded_value = var17 %}{% when 18 %}{% assign loaded_value = var18 %}{% when 19 %}{% assign loaded_value = var19 %}{% when 20 %}{% assign loaded_value = var20 %}{% when 21 %}{% assign loaded_value = var21 %}{% when 22 %}{% assign loaded_value = var22 %}{% when 23 %}{% assign loaded_value = var23 %}{% when 24 %}{% assign loaded_value = var24 %}{% when 25 %}{% assign loaded_value = var25 %}{% when 26 %}{% assign loaded_value = var26 %}{% when 27 %}{% assign loaded_value = var27 %}{% when 28 %}{% assign loaded_value = var28 %}{% when 29 %}{% assign loaded_value = var29 %}{% when 30 %}{% assign loaded_value = var30 %}{% when 31 %}{% assign loaded_value = var31 %}{% when 32 %}{% assign loaded_value = var32 %}{% when 33 %}{% assign loaded_value = var33 %}{% when 34 %}{% assign loaded_value = var34 %}{% when 35 %}{% assign loaded_value = var35 %}{% when 36 %}{% assign loaded_value = var36 %}{% when 37 %}{% assign loaded_value = var37 %}{% when 38 %}{% assign loaded_value = var38 %}{% when 39 %}{% assign loaded_value = var39 %}{% when 40 %}{% assign loaded_value = var40 %}{% when 41 %}{% assign loaded_value = var41 %}{% when 42 %}{% assign loaded_value = var42 %}{% when 43 %}{% assign loaded_value = var43 %}{% when 44 %}{% assign loaded_value = var44 %}{% when 45 %}{% assign loaded_value = var45 %}{% when 46 %}{% assign loaded_value = var46 %}{% when 47 %}{% assign loaded_value = var47 %}{% when 48 %}{% assign loaded_value = var48 %}{% when 49 %}{% assign loaded_value = var49 %}{% when 50 %}{% assign loaded_value = var50 %}{% when 51 %}{% assign loaded_value = var51 %}{% when 52 %}{% assign loaded_value = var52 %}{% when 53 %}{% assign loaded_value = var53 %}{% when 54 %}{% assign loaded_value = var54 %}{% when 55 %}{% assign loaded_value = var55 %}{% when 56 %}{% assign loaded_value = var56 %}{% when 57 %}{% assign loaded_value = var57 %}{% when 58 %}{% assign loaded_value = var58 %}{% when 59 %}{% assign loaded_value = var59 %}{% when 60 %}{% assign loaded_value = var60 %}{% when 61 %}{% assign loaded_value = var61 %}{% when 62 %}{% assign loaded_value = var62 %}{% when 63 %}{% assign loaded_value = var63 %}{% when 64 %}{% assign loaded_value = var64 %}{% when 65 %}{% assign loaded_value = var65 %}{% when 66 %}{% assign loaded_value = var66 %}{% when 67 %}{% assign loaded_value = var67 %}{% when 68 %}{% assign loaded_value = var68 %}{% when 69 %}{% assign loaded_value = var69 %}{% when 70 %}{% assign loaded_value = var70 %}{% when 71 %}{% assign loaded_value = var71 %}{% when 72 %}{% assign loaded_value = var72 %}{% when 73 %}{% assign loaded_value = var73 %}{% when 74 %}{% assign loaded_value = var74 %}{% when 75 %}{% assign loaded_value = var75 %}{% when 76 %}{% assign loaded_value = var76 %}{% when 77 %}{% assign loaded_value = var77 %}{% when 78 %}{% assign loaded_value = var78 %}{% when 79 %}{% assign loaded_value = var79 %}{% when 80 %}{% assign loaded_value = var80 %}{% when 81 %}{% assign loaded_value = var81 %}{% when 82 %}{% assign loaded_value = var82 %}{% when 83 %}{% assign loaded_value = var83 %}{% when 84 %}{% assign loaded_value = var84 %}{% when 85 %}{% assign loaded_value = var85 %}{% when 86 %}{% assign loaded_value = var86 %}{% when 87 %}{% assign loaded_value = var87 %}{% when 88 %}{% assign loaded_value = var88 %}{% when 89 %}{% assign loaded_value = var89 %}{% when 90 %}{% assign loaded_value = var90 %}{% when 91 %}{% assign loaded_value = var91 %}{% when 92 %}{% assign loaded_value = var92 %}{% when 93 %}{% assign loaded_value = var93 %}{% when 94 %}{% assign loaded_value = var94 %}{% when 95 %}{% assign loaded_value = var95 %}{% when 96 %}{% assign loaded_value = var96 %}{% when 97 %}{% assign loaded_value = var97 %}{% when 98 %}{% assign loaded_value = var98 %}{% when 99 %}{% assign loaded_value = var99 %}{% endcase %}{% assign data_stack_top = data_stack_top | plus: 1 %}{% assign data_stack = data_stack | append: " " | append: loaded_value %}{% when "r" %}{% if return_stack_top == 0 %}{% assign broken = true %}{% break %}{% else %}{% assign var_stack_array = var_stack | split: " " %}{% assign stack_frame = var_stack_array | last %}{% assign var_stack = var_stack | truncatewords: var_stack_top | remove: "..." %}{% assign var_stack_top = var_stack_top | minus: 1 %}{% assign __split = stack_frame | split: '/' %}{% assign var0 = __split[0] %}{% assign var1 = __split[1] %}{% assign var2 = __split[2] %}{% assign var3 = __split[3] %}{% assign var4 = __split[4] %}{% assign var5 = __split[5] %}{% assign var6 = __split[6] %}{% assign var7 = __split[7] %}{% assign var8 = __split[8] %}{% assign var9 = __split[9] %}{% assign var10 = __split[10] %}{% assign var11 = __split[11] %}{% assign var12 = __split[12] %}{% assign var13 = __split[13] %}{% assign var14 = __split[14] %}{% assign var15 = __split[15] %}{% assign var16 = __split[16] %}{% assign var17 = __split[17] %}{% assign var18 = __split[18] %}{% assign var19 = __split[19] %}{% assign var20 = __split[20] %}{% assign var21 = __split[21] %}{% assign var22 = __split[22] %}{% assign var23 = __split[23] %}{% assign var24 = __split[24] %}{% assign var25 = __split[25] %}{% assign var26 = __split[26] %}{% assign var27 = __split[27] %}{% assign var28 = __split[28] %}{% assign var29 = __split[29] %}{% assign var30 = __split[30] %}{% assign var31 = __split[31] %}{% assign var32 = __split[32] %}{% assign var33 = __split[33] %}{% assign var34 = __split[34] %}{% assign var35 = __split[35] %}{% assign var36 = __split[36] %}{% assign var37 = __split[37] %}{% assign var38 = __split[38] %}{% assign var39 = __split[39] %}{% assign var40 = __split[40] %}{% assign var41 = __split[41] %}{% assign var42 = __split[42] %}{% assign var43 = __split[43] %}{% assign var44 = __split[44] %}{% assign var45 = __split[45] %}{% assign var46 = __split[46] %}{% assign var47 = __split[47] %}{% assign var48 = __split[48] %}{% assign var49 = __split[49] %}{% assign var50 = __split[50] %}{% assign var51 = __split[51] %}{% assign var52 = __split[52] %}{% assign var53 = __split[53] %}{% assign var54 = __split[54] %}{% assign var55 = __split[55] %}{% assign var56 = __split[56] %}{% assign var57 = __split[57] %}{% assign var58 = __split[58] %}{% assign var59 = __split[59] %}{% assign var60 = __split[60] %}{% assign var61 = __split[61] %}{% assign var62 = __split[62] %}{% assign var63 = __split[63] %}{% assign var64 = __split[64] %}{% assign var65 = __split[65] %}{% assign var66 = __split[66] %}{% assign var67 = __split[67] %}{% assign var68 = __split[68] %}{% assign var69 = __split[69] %}{% assign var70 = __split[70] %}{% assign var71 = __split[71] %}{% assign var72 = __split[72] %}{% assign var73 = __split[73] %}{% assign var74 = __split[74] %}{% assign var75 = __split[75] %}{% assign var76 = __split[76] %}{% assign var77 = __split[77] %}{% assign var78 = __split[78] %}{% assign var79 = __split[79] %}{% assign var80 = __split[80] %}{% assign var81 = __split[81] %}{% assign var82 = __split[82] %}{% assign var83 = __split[83] %}{% assign var84 = __split[84] %}{% assign var85 = __split[85] %}{% assign var86 = __split[86] %}{% assign var87 = __split[87] %}{% assign var88 = __split[88] %}{% assign var89 = __split[89] %}{% assign var90 = __split[90] %}{% assign var91 = __split[91] %}{% assign var92 = __split[92] %}{% assign var93 = __split[93] %}{% assign var94 = __split[94] %}{% assign var95 = __split[95] %}{% assign var96 = __split[96] %}{% assign var97 = __split[97] %}{% assign var98 = __split[98] %}{% assign var99 = __split[99] %}{% assign return_stack_array = return_stack | split: " " %}{% assign return_pc = return_stack_array | last %}{% assign return_stack = return_stack | truncatewords: return_stack_top | remove: "..." %}{% assign return_stack_top = return_stack_top | minus: 1 %}{% assign return_pc = return_pc | plus: 0 %}{% assign next_pc = return_pc %}{% endif %}{% endcase %}{% assign pc = next_pc %}{% endfor %}{% if broken  %}{% break %}{% endif %}{% endfor %}{% if broken  %}{% break %}{% endif %}{% endfor %}<pre><code>
constants: {{ constants | join: ", " }}
bytecode: {{ bytecode }}
--- Output ----------------------------------------------------------
{{ output }}
---------------------------------------------------------------------
Finished in {{ cycle_count }} cycles
End stack: {{ data_stack }}
Stack top: {{ data_stack_top }}
PC: {{ pc }}
</code></pre>
LIQUID

template = Liquid::Template.parse(source)

def benchmark
  context = Liquid::Context.new
  strainer = Liquid::Strainer.create(context)

  system('hr -')

  template = Liquid::Template.parse(source)
  ruby =  Compiler.compile(template)
  puts ruby

  system('hr / ')

  puts
  puts "Compose + parse + render"
  system('hr - ')

  start = Time.now
  template = Liquid::Template.parse(source)
  ruby =  Compiler.compile(template)
  instructions = RubyVM::InstructionSequence.compile(ruby)
  instructions.eval.call(STDOUT, strainer)
  puts Time.now - start

  puts
  puts "Render cached"
  system('hr - ')

  start = Time.now
  instructions.eval.call(STDOUT, strainer)
  puts Time.now - start

  puts
  puts "Legacy rendering"
  system('hr - ')

  start = Time.now
  template = Liquid::Template.parse(source)
  puts template.render
  puts Time.now - start
end


# ap template

context = Liquid::Context.new
strainer = Liquid::Strainer.create(context)
template = Liquid::Template.parse(source)

template = Liquid::Template.parse(source)

system('hr -')

ruby =  Compiler.compile(template)

File.open('compiled.rb', 'wb') do |f|
  f.write(ruby)
end
puts ruby

system('hr /')

instructions = RubyVM::InstructionSequence.compile(ruby)
instructions.eval.call(STDOUT, strainer)
system('hr \\\\')
