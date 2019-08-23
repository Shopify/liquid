require 'liquid'
require 'ap'

AwesomePrint.defaults = {
  raw: true
}

source = <<~LIQUID

{% assign prime_max = 10000 %}

{% for candidate in (3..prime_max) %}{% assign prime = 1 %}{% assign less = candidate | minus: 1 %}{% for divisor in (2..less) %}{% assign rem = candidate | modulo: divisor %}{% if rem == 0 %}{% assign prime = 0 %}{% break %}{% endif %}{% endfor %}{% if prime == 1 %}{{ candidate }}, {% endif %}{% endfor %}
LIQUID

template = Liquid::Template.parse(source)

def yell!(message)
  system("toilet --gay #{message}")
end

def derp(message, expr)
  yell! message
  ap expr
  exit
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
    left = make_variable_expr(condition.left)
    right = make_variable_expr(condition.right)
    line "if #{left} #{condition.operator} #{right}"
      indent { condition.attachment.nodelist.each(&method(:compile)) }
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
      when Liquid::VariableLookup
        var(variable.name.name)
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

ap template

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
