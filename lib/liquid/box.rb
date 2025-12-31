# frozen_string_literal: true

# Liquid::Box - Secure sandboxed execution environment for compiled Liquid templates
#
# On Ruby 4.0+, this uses the native Ruby::Box for true isolation.
# On earlier Ruby versions, this provides a polyfill that WARNS about insecurity.
#
# == SECURITY WARNING
#
# The polyfill on Ruby < 4.0 provides NO REAL SECURITY. It's a compatibility shim
# that allows code to run, but malicious templates could potentially escape.
# Use Ruby 4.0+ in production for actual sandboxing.
#
# == Usage
#
#   template = Liquid::Template.parse("Hello {{ name }}!")
#   compiled = template.compile_to_ruby
#
#   # compiled is a Liquid::CompiledTemplate which wraps a Box
#   result = compiled.render({ "name" => "World" })
#   # => "Hello World!"
#
#   # Access the generated Ruby code:
#   puts compiled.source
#

module Liquid
  # Check if we have Ruby 4.0's native Box AND it's enabled
  # Ruby::Box may be defined but disabled (requires RUBY_BOX=1 env var before Ruby starts)
  RUBY_BOX_AVAILABLE = begin
    if defined?(Ruby::Box)
      # Try to create a box to see if it's actually enabled
      test_box = Ruby::Box.new
      true
    else
      false
    end
  rescue RuntimeError => e
    # Ruby::Box exists but is disabled
    false
  end

  unless RUBY_BOX_AVAILABLE
    # Warn once on load that we're using the insecure polyfill
    warn "[Liquid::Box] WARNING: Ruby::Box not available or disabled. " \
         "Using INSECURE polyfill. Compiled templates are NOT sandboxed! " \
         "(Ruby 4.0+ with RUBY_BOX=1 required for secure execution)" if $VERBOSE
  end

  # Polyfill for Ruby::Box when not available (Ruby < 4.0)
  # This provides the same API but NO SECURITY - it just evals code in the main environment.
  module BoxPolyfill
    class Box
      def initialize
        @constants = {}
        @binding = TOPLEVEL_BINDING.dup
      end

      def eval(code)
        ::Kernel.eval(code, @binding)
      end

      def const_get(name)
        ::Object.const_get(name)
      end
    end
  end

  # Liquid::Box wraps either Ruby::Box (secure) or BoxPolyfill::Box (insecure)
  #
  # This provides a secure sandboxed environment for executing compiled Liquid templates.
  # On Ruby 4.0+, templates run in true isolation with dangerous methods removed.
  # On Ruby < 4.0, templates run without sandboxing (development/testing only).
  #
  class Box
    attr_reader :box

    class << self
      # Returns true if we have real sandboxing (Ruby 4.0+)
      def secure?
        RUBY_BOX_AVAILABLE
      end

      # Create a pre-configured box for Liquid template execution.
      # This is the recommended way to get a Box instance.
      def create_for_liquid
        box = new
        box.load_liquid_runtime!
        box.lock!
        box
      end
    end

    def initialize
      @box = RUBY_BOX_AVAILABLE ? Ruby::Box.new : BoxPolyfill::Box.new
      @locked = false
      @user_constants = []
      @warned_insecure = false
    end

    # Load code into the sandbox before locking.
    # Use this to define filters, helpers, and the Liquid runtime.
    def load_runtime(code)
      raise "Cannot load runtime after lock!" if @locked
      before = @box.eval("Object.constants")
      @box.eval(code)
      after = @box.eval("Object.constants")
      @user_constants += (after - before).map(&:to_s)
    end

    # Load the standard Liquid runtime helpers (LR module).
    # Call this before lock! to set up the execution environment.
    # The runtime provides all helper methods that compiled templates use.
    def load_liquid_runtime!
      raise "Cannot load runtime after lock!" if @locked

      if RUBY_BOX_AVAILABLE
        # Add gem paths to box's load_path so it can find base64, bigdecimal, etc.
        # These are safe, side-effect-free libs that only provide pure functions
        setup_gem_load_paths!

        # Load dependencies INTO the box - we need the actual libraries,
        # not reimplementations, to handle all edge cases correctly
        @box.require('cgi')
        @box.require('base64')
        @box.require('bigdecimal')
        @box.require('bigdecimal/util')  # For String#to_d etc.
        @box.require('date')  # For date filter
        @box.require('time')  # For Time.parse

        # Now load the runtime which captures method references from these
        @box.require(RUNTIME_PATH)
      else
        # Polyfill: just require it normally
        require 'cgi'
        require 'base64'
        require 'bigdecimal'
        require 'bigdecimal/util'
        require 'date'
        require 'time'
        require RUNTIME_PATH
      end

      # Track constants to preserve after lock
      @user_constants << "LR"
      @user_constants << "LiquidRuntime"
      @user_constants << "CGI"
      @user_constants << "Base64"
      @user_constants << "BigDecimal"
      @user_constants << "Date"
      @user_constants << "DateTime"
      @user_constants << "Time"
      @user_constants << "Liquid"  # For Liquid::Compile::CompiledContext
    end

    # Add gem paths to the box's load_path so require works for gems
    def setup_gem_load_paths!
      return unless RUBY_BOX_AVAILABLE

      # Find gem paths from the main environment's $LOAD_PATH
      # and from Gem.path if available
      gem_lib_paths = []

      # Method 1: Find from $LOAD_PATH entries containing "gems"
      $LOAD_PATH.each do |path|
        gem_lib_paths << path if path.include?('/gems/')
      end

      # Method 2: Use Gem.path if available
      if defined?(Gem) && Gem.respond_to?(:path)
        Gem.path.each do |gem_path|
          Dir.glob("#{gem_path}/gems/*/lib").each do |lib_path|
            gem_lib_paths << lib_path
          end
        end
      end

      # Add unique paths to box's load_path
      gem_lib_paths.uniq.each do |path|
        @box.load_path << path unless @box.load_path.include?(path)
      end
    end

    # Lock the sandbox. After this:
    # - No more runtime can be loaded
    # - Dangerous methods are removed (on Ruby 4.0+)
    # - Templates can be compiled and executed
    def lock!
      return if @locked

      if RUBY_BOX_AVAILABLE
        apply_sandbox!
      else
        warn_insecure!
      end

      @locked = true
    end

    def locked?
      @locked
    end

    # Returns true if this box provides real security (Ruby 4.0+)
    def secure?
      RUBY_BOX_AVAILABLE
    end

    # Evaluate code in the sandbox.
    # Use this to compile templates into the sandbox.
    def eval(code)
      raise "Must call lock! before eval" unless @locked
      warn_insecure! unless RUBY_BOX_AVAILABLE
      @box.eval(code)
    end

    # Get a constant from the sandbox by name.
    def const_get(name)
      @box.const_get(name)
    end

    def [](name)
      const_get(name)
    end

    private

    def warn_insecure!
      return if @warned_insecure
      @warned_insecure = true

      $stderr.puts <<~WARNING
        ╔══════════════════════════════════════════════════════════════════════════════╗
        ║ SECURITY WARNING: Liquid::Box running WITHOUT sandboxing                     ║
        ║                                                                              ║
        ║ Ruby::Box requires Ruby 4.0+. On earlier versions, compiled Liquid templates ║
        ║ execute with FULL Ruby capabilities. This is NOT SECURE for untrusted input. ║
        ║                                                                              ║
        ║ For production use with untrusted templates, upgrade to Ruby 4.0+.           ║
        ╚══════════════════════════════════════════════════════════════════════════════╝
      WARNING
    end

    # Apply sandbox restrictions (Ruby 4.0+ only)
    def apply_sandbox!
      neuter_file_system!
      neuter_process_control!
      neuter_concurrency!
      neuter_introspection!
      neuter_serialization!
      neuter_time!
      neuter_environment!
      neuter_kernel!
      neuter_basic_object!
      neuter_object!
      neuter_main_singleton!
      neuter_module!
      cleanup_globals!
      remove_dangerous_constants!
    end

    def neuter_file_system!
      @box.eval(<<~'RUBY')
        class << File
          instance_methods(false).each { |m| undef_method(m) rescue nil }
        end
        class << IO
          instance_methods(false).each { |m| undef_method(m) rescue nil }
        end
        class << Dir
          instance_methods(false).each { |m| undef_method(m) rescue nil }
        end
        class IO
          [:read, :write, :gets, :puts, :print, :readline, :readlines, :getc, :getbyte,
           :sysread, :syswrite, :close, :eof, :eof?, :rewind, :seek].each do |m|
            undef_method(m) rescue nil
          end
        end
      RUBY
    end

    def neuter_process_control!
      @box.eval(<<~'RUBY')
        class << Process
          instance_methods(false).each { |m| undef_method(m) rescue nil }
        end
        class << Signal
          instance_methods(false).each { |m| undef_method(m) rescue nil }
        end
      RUBY
    end

    def neuter_concurrency!
      @box.eval(<<~'RUBY')
        class << Thread
          [:new, :start, :fork, :kill, :exit, :pass, :stop, :main, :current, :list,
           :abort_on_exception, :abort_on_exception=].each { |m| undef_method(m) rescue nil }
        end
        class << Fiber
          [:new, :yield, :current].each { |m| undef_method(m) rescue nil }
        end
        if defined?(Ractor)
          class << Ractor
            instance_methods(false).each { |m| undef_method(m) rescue nil }
          end
        end
      RUBY
    end

    def neuter_introspection!
      @box.eval(<<~'RUBY')
        class << ObjectSpace
          instance_methods(false).each { |m| undef_method(m) rescue nil }
        end
        class << GC
          instance_methods(false).each { |m| undef_method(m) rescue nil }
        end
        if defined?(RubyVM)
          class << RubyVM
            instance_methods(false).each { |m| undef_method(m) rescue nil }
          end
          if defined?(RubyVM::InstructionSequence)
            class << RubyVM::InstructionSequence
              instance_methods(false).each { |m| undef_method(m) rescue nil }
            end
          end
        end
        class << TracePoint
          [:new, :stat, :trace].each { |m| undef_method(m) rescue nil }
        end
      RUBY
    end

    def neuter_serialization!
      @box.eval(<<~'RUBY')
        class << Marshal
          [:dump, :load, :restore].each { |m| undef_method(m) rescue nil }
        end
      RUBY
    end

    def neuter_time!
      # Time is mostly safe for date filters - only neuter methods that could be used
      # to manipulate system state or sleep/wait.
      # Keep: now, at, parse, mktime - needed for date filter
      # Remove: nothing for now - Time is pure computation
      #
      # Note: If you want stricter isolation, templates should receive "now" via assigns
      # @box.eval(<<~'RUBY')
      #   class << Time
      #     [:now, :new, :at, :mktime, :local, :utc, :gm].each { |m| undef_method(m) rescue nil }
      #   end
      # RUBY
    end

    def neuter_environment!
      @box.eval(<<~'RUBY')
        ENV.clear rescue nil
        class << ENV
          instance_methods(false).each { |m| undef_method(m) rescue nil }
        end
      RUBY
    end

    def neuter_kernel!
      @box.eval(<<~'RUBY')
        module Kernel
          [:eval, :`, :system, :exec, :spawn, :fork, :binding,
           :open, :require, :require_relative, :load, :autoload, :autoload?,
           :gets, :readline, :readlines, :select, :test,
           :trap, :exit, :exit!, :abort, :at_exit, :syscall, :sleep,
           :puts, :print, :printf, :putc, :p, :pp, :warn,
           :caller, :caller_locations, :set_trace_func, :trace_var, :untrace_var,
           :global_variables, :local_variables,
           :gem, :gem_original_require, :Pathname,
          ].each { |m| undef_method(m) rescue nil }
        end

        class << Kernel
          [:eval, :`, :system, :exec, :spawn, :fork, :binding,
           :open, :require, :require_relative, :load,
           :puts, :print, :p, :pp, :warn,
          ].each { |m| undef_method(m) rescue nil }
        end
      RUBY
    end

    def neuter_basic_object!
      @box.eval(<<~'RUBY')
        class BasicObject
          undef_method(:instance_eval) rescue nil
          undef_method(:instance_exec) rescue nil
          # Don't undef __send__ - it causes warnings and is equivalent to send
          # which we already restrict via public_send
        end
      RUBY
    end

    def neuter_object!
      @box.eval(<<~'RUBY')
        class Object
          # Keep public_send - it's safe (only calls public methods) and useful
          [:gem, :gem_original_require, :require, :require_relative, :load,
           :display, :define_singleton_method,
           :instance_variable_set, :remove_instance_variable,
           :extend, :send,
          ].each { |m| undef_method(m) rescue nil }
        end
      RUBY
    end

    def neuter_main_singleton!
      # 'using' is defined on main's singleton class, must remove before undef_method is gone
      @box.eval(<<~'RUBY')
        class << self
          undef_method(:using) rescue nil
        end
      RUBY
    end

    def neuter_module!
      @box.eval(<<~'RUBY')
        class Module
          undef_method(:refine) rescue nil
          undef_method(:using) rescue nil
          undef_method(:const_set) rescue nil
          undef_method(:remove_const) rescue nil
          undef_method(:include) rescue nil
          undef_method(:prepend) rescue nil
          undef_method(:extend) rescue nil
          undef_method(:class_eval) rescue nil
          undef_method(:module_eval) rescue nil
          undef_method(:class_exec) rescue nil
          undef_method(:module_exec) rescue nil
          undef_method(:define_method) rescue nil
          undef_method(:alias_method) rescue nil
          undef_method(:module_function) rescue nil
          undef_method(:prepend_features) rescue nil
          undef_method(:append_features) rescue nil
          undef_method(:extend_object) rescue nil
          undef_method(:public) rescue nil
          undef_method(:private) rescue nil
          undef_method(:protected) rescue nil
          undef_method(:attr) rescue nil
          undef_method(:attr_reader) rescue nil
          undef_method(:attr_writer) rescue nil
          undef_method(:attr_accessor) rescue nil
          # Remove escape hatches LAST
          undef_method(:remove_method) rescue nil
          undef_method(:undef_method) rescue nil
          undef_method(:send) rescue nil
          undef_method(:public_send) rescue nil
        end

        class Class
          undef_method(:send) rescue nil
          undef_method(:public_send) rescue nil
        end
      RUBY
    end

    def cleanup_globals!
      @box.eval(<<~'RUBY')
        $stdin = nil
        $stdout = nil
        $stderr = nil
        $LOAD_PATH.clear rescue nil
        $LOAD_PATH.freeze rescue nil
        $LOADED_FEATURES.clear rescue nil
        $LOADED_FEATURES.freeze rescue nil
        ARGV.clear rescue nil
        ARGV.freeze rescue nil
      RUBY
    end

    def remove_dangerous_constants!
      keep = %w[
        BasicObject Object Module Class Kernel
        String Integer Float Numeric Rational Complex
        Array Hash Range Set
        Symbol Regexp MatchData
        TrueClass FalseClass NilClass
        Proc Method UnboundMethod
        Struct Data
        Comparable Enumerable Enumerator
        StandardError RuntimeError ArgumentError TypeError NameError
        NoMethodError KeyError IndexError StopIteration FrozenError
        ZeroDivisionError RangeError FloatDomainError LocalJumpError
        Math Random
        Exception SystemStackError
      ] + @user_constants

      @box.eval(<<~RUBY)
        _keep = #{keep.inspect}
        (Object.constants.map(&:to_s) - _keep).each do |c|
          Object.send(:remove_const, c.to_sym) rescue nil
        end
        (Kernel.constants.map(&:to_s) - _keep).each do |c|
          Kernel.send(:remove_const, c.to_sym) rescue nil
        end
      RUBY
    end

    # Path to the runtime file that gets loaded into the sandbox
    RUNTIME_PATH = File.expand_path('compile/runtime.rb', __dir__)
  end
end
