# frozen_string_literal: true

# Liquid Ruby Compiler
#
# This module provides the ability to compile Liquid templates to pure Ruby code.
# Compiled templates execute in a secure sandbox using Liquid::Box (on Ruby 4.0+).
#
# ## Usage
#
#   template = Liquid::Template.parse("Hello, {{ name }}!")
#   compiled = template.compile_to_ruby
#
#   # Render securely (sandboxed on Ruby 4.0+)
#   result = compiled.render({ "name" => "World" })
#   # => "Hello, World!"
#
#   # Access the generated Ruby source
#   puts compiled.source
#
#   # Check security status
#   compiled.secure?  # => true on Ruby 4.0+
#
# ## Security
#
# On Ruby 4.0+, compiled templates execute in a Ruby::Box sandbox that prevents:
# - File system access (File, IO, Dir)
# - Process control (system, exec, spawn, fork)
# - Network access (Socket, Net::HTTP)
# - Code loading (require, load, eval)
# - Dangerous metaprogramming (define_method, const_set, send)
#
# On Ruby < 4.0, a polyfill is used that prints a security warning to STDERR.
# The polyfill provides NO ACTUAL SECURITY - use Ruby 4.0+ in production.
#
# ## Performance Benefits
#
# Compiled templates are ~1.5x faster than interpreted Liquid because:
#
# 1. **No Context Object**: Variables accessed directly from assigns hash
# 2. **No Filter Dispatch**: Filters compiled to direct Ruby calls
# 3. **No Resource Limits**: No per-node overhead for limit tracking
# 4. **Native Scoping**: Ruby's block scoping instead of manual stacks
# 5. **Direct Concatenation**: Output built with << operations
# 6. **Native Control Flow**: break/continue use Ruby's throw/catch
# 7. **No to_liquid Calls**: Values used directly
# 8. **No Profiling Hooks**: No profiler overhead
#
# ## Limitations
#
# - {% render %} and {% include %} resolved at compile time when possible
# - Custom tags need explicit compiler implementations
# - Custom filters must be available at runtime
#
module Liquid
  module Compile
    autoload :CompiledTemplate, 'liquid/compile/compiled_template'
    autoload :CompiledContext, 'liquid/compile/compiled_context'
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
