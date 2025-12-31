# frozen_string_literal: true

# Liquid Ruby Compiler
#
# This module provides the ability to compile Liquid templates to pure Ruby code.
# The compiled code can be eval'd to create a proc that renders the template
# without needing the Liquid library at runtime.
#
# ## Usage
#
#   template = Liquid::Template.parse("Hello, {{ name }}!")
#   ruby_code = template.compile_to_ruby
#   render_proc = eval(ruby_code)
#   result = render_proc.call({ "name" => "World" })
#   # => "Hello, World!"
#
# ## Optimization Opportunities
#
# The compiled Ruby code has several significant advantages over interpreted Liquid:
#
# 1. **No Context Object**: Variables are extracted directly from the assigns hash
#    and accessed without the Context abstraction layer.
#
# 2. **No Filter Invocation Overhead**: Filters are compiled to direct Ruby method
#    calls rather than going through context.invoke().
#
# 3. **No Resource Limits Tracking**: The compiled code doesn't track render
#    scores, write scores, or assign scores, eliminating per-node overhead.
#
# 4. **No Stack-based Scoping**: Ruby's native block scoping is used instead
#    of manually managing scope stacks.
#
# 5. **Direct String Concatenation**: Output is built with direct << operations.
#
# 6. **Native Control Flow**: break/continue use Ruby's throw/catch mechanism.
#
# 7. **No to_liquid Calls**: Values are used directly without conversion.
#
# 8. **No Profiling Hooks**: No profiler overhead in the generated code.
#
# 9. **No Exception Rendering**: Errors propagate naturally.
#
# ## Limitations
#
# - {% render %} and {% include %} tags require runtime support
# - Custom tags need explicit compiler implementations
# - Custom filters need to be available at runtime
#
module Liquid
  module Compile
    autoload :CompiledTemplate, 'liquid/compile/compiled_template'
    autoload :CodeGenerator, 'liquid/compile/code_generator'
    autoload :RubyCompiler, 'liquid/compile/ruby_compiler'
    autoload :ExpressionCompiler, 'liquid/compile/expression_compiler'
    autoload :FilterCompiler, 'liquid/compile/filter_compiler'
    autoload :VariableCompiler, 'liquid/compile/variable_compiler'
    autoload :BlockBodyCompiler, 'liquid/compile/block_body_compiler'
    autoload :ConditionCompiler, 'liquid/compile/condition_compiler'
    autoload :SourceMapper, 'liquid/compile/source_mapper'

    module Tags
      autoload :IfCompiler, 'liquid/compile/tags/if_compiler'
      autoload :UnlessCompiler, 'liquid/compile/tags/unless_compiler'
      autoload :CaseCompiler, 'liquid/compile/tags/case_compiler'
      autoload :ForCompiler, 'liquid/compile/tags/for_compiler'
      autoload :AssignCompiler, 'liquid/compile/tags/assign_compiler'
      autoload :CaptureCompiler, 'liquid/compile/tags/capture_compiler'
      autoload :CycleCompiler, 'liquid/compile/tags/cycle_compiler'
      autoload :IncrementCompiler, 'liquid/compile/tags/increment_compiler'
      autoload :DecrementCompiler, 'liquid/compile/tags/decrement_compiler'
      autoload :RawCompiler, 'liquid/compile/tags/raw_compiler'
      autoload :EchoCompiler, 'liquid/compile/tags/echo_compiler'
      autoload :BreakCompiler, 'liquid/compile/tags/break_compiler'
      autoload :ContinueCompiler, 'liquid/compile/tags/continue_compiler'
      autoload :CommentCompiler, 'liquid/compile/tags/comment_compiler'
      autoload :TableRowCompiler, 'liquid/compile/tags/tablerow_compiler'
      autoload :RenderCompiler, 'liquid/compile/tags/render_compiler'
      autoload :IncludeCompiler, 'liquid/compile/tags/include_compiler'
      autoload :IfchangedCompiler, 'liquid/compile/tags/ifchanged_compiler'
    end
  end
end
