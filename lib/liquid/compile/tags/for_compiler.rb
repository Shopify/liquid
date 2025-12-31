# frozen_string_literal: true

require 'set'

module Liquid
  module Compile
    module Tags
      # Compiles {% for %} / {% else %} / {% endfor %} tags
      #
      # Supports:
      # - Iteration: {% for item in collection %}
      # - Limit/Offset: {% for item in collection limit:3 offset:2 %}
      # - Reversed: {% for item in collection reversed %}
      # - Forloop object: forloop.index, forloop.first, forloop.last, etc.
      # - Else block: {% for item in collection %}...{% else %}empty{% endfor %}
      #
      # Optimizations:
      # - Detects break/continue usage at compile time
      # - Uses while loop with index for minimal overhead
      # - Break implemented with flag variable (no catch/throw)
      # - Continue implemented with next (native Ruby)
      # - Avoids Hash allocation for forloop when not used
      class ForCompiler
        def self.compile(tag, compiler, code)
          var_name = tag.variable_name
          collection_expr = ExpressionCompiler.compile(tag.collection_name, compiler)

          # Generate unique variable names for this loop
          coll_var = compiler.generate_var_name("coll")
          idx_var = compiler.generate_var_name("idx")
          len_var = compiler.generate_var_name("len")

          # Evaluate the collection and convert to array for indexed access
          # After this, coll_var is guaranteed to be an Array (or nil)
          code.line "#{coll_var} = #{collection_expr}"
          code.line "#{coll_var} = LR.to_array(#{coll_var})"

          # Handle limit and offset
          if tag.from || tag.limit
            compile_slice(tag, coll_var, compiler, code)
          end

          # Handle reversed
          if tag.instance_variable_get(:@reversed)
            code.line "#{coll_var} = #{coll_var}.reverse"
          end

          # Check if collection is empty for else block
          for_block = tag.instance_variable_get(:@for_block)
          else_block = tag.instance_variable_get(:@else_block)

          if else_block
            code.line "if #{coll_var}.nil? || #{coll_var}.empty?"
            code.indent do
              BlockBodyCompiler.compile(else_block, compiler, code)
            end
            code.line "else"
            code.indent do
              compile_loop(tag, var_name, coll_var, idx_var, len_var, for_block, compiler, code)
            end
            code.line "end"
          else
            code.line "if #{coll_var} && !#{coll_var}.empty?"
            code.indent do
              compile_loop(tag, var_name, coll_var, idx_var, len_var, for_block, compiler, code)
            end
            code.line "end"
          end
        end

        private

        def self.compile_slice(tag, coll_var, compiler, code)
          from_expr = if tag.from == :continue
            # Continue from previous offset - we'd need register tracking for this
            # For now, default to 0
            "0"
          elsif tag.from
            ExpressionCompiler.compile(tag.from, compiler)
          else
            "0"
          end

          if tag.limit
            limit_expr = ExpressionCompiler.compile(tag.limit, compiler)
            code.line "#{coll_var} = #{coll_var}[LR.to_integer(#{from_expr}), LR.to_integer(#{limit_expr})] || []"
          else
            code.line "#{coll_var} = #{coll_var}.drop(LR.to_integer(#{from_expr}))"
          end
        end

        def self.compile_loop(tag, var_name, coll_var, idx_var, len_var, for_block, compiler, code)
          # Analyze loop body for break/continue usage and forloop access
          has_break = contains_tag?(for_block, Break)
          forloop_props = detect_forloop_properties(for_block)
          uses_forloop = !forloop_props.empty?

          # Calculate length (needed for forloop or bounds checking)
          code.line "#{len_var} = #{coll_var}.length"
          code.line "#{idx_var} = 0"

          # Break uses a flag variable - no catch/throw overhead
          if has_break
            break_var = compiler.generate_var_name("brk")
            code.line "#{break_var} = false"
            code.line "while #{idx_var} < #{len_var} && !#{break_var}"
          else
            code.line "while #{idx_var} < #{len_var}"
          end

          # Check if all forloop properties can be inlined (no hash needed)
          inlinable_props = %w[index index0 rindex rindex0 first last length name]
          needs_forloop_hash = uses_forloop && !forloop_props.all? { |p| inlinable_props.include?(p) }

          code.indent do
            # Set the loop variable directly from array index
            code.line "assigns[#{var_name.inspect}] = #{coll_var}[#{idx_var}]"

            # Only create forloop hash if we have properties that can't be inlined
            if needs_forloop_hash
              compile_forloop_hash(tag, idx_var, len_var, code)
            end

            # Compile the loop body
            # The BreakCompiler/ContinueCompiler will emit the right code
            # based on the context we pass through the compiler
            compiler.push_loop_context(
              break_var: has_break ? break_var : nil,
              idx_var: idx_var,
              len_var: len_var,
              loop_name: tag.instance_variable_get(:@name)
            )
            BlockBodyCompiler.compile(for_block, compiler, code)
            compiler.pop_loop_context

            # Increment index
            code.line "#{idx_var} += 1"
          end
          code.line "end"

          # Clean up
          code.line "assigns.delete(#{var_name.inspect})"
          code.line "assigns.delete('forloop')" if needs_forloop_hash
        end

        def self.compile_forloop_hash(tag, idx_var, len_var, code)
          loop_name = tag.instance_variable_get(:@name)
          code.line "assigns['forloop'] = {"
          code.indent do
            code.line "'name' => #{loop_name.inspect},"
            code.line "'length' => #{len_var},"
            code.line "'index' => #{idx_var} + 1,"
            code.line "'index0' => #{idx_var},"
            code.line "'rindex' => #{len_var} - #{idx_var},"
            code.line "'rindex0' => #{len_var} - #{idx_var} - 1,"
            code.line "'first' => #{idx_var} == 0,"
            code.line "'last' => #{idx_var} == #{len_var} - 1,"
          end
          code.line "}"
        end

        # Check if a block body contains a specific tag type (recursively)
        def self.contains_tag?(body, tag_class)
          return false if body.nil?
          nodelist = body.nodelist
          return false if nodelist.nil?

          nodelist.any? do |node|
            case node
            when tag_class
              true
            when Block
              # Check nested blocks (if, for, case, etc.)
              contains_tag?(node.instance_variable_get(:@body), tag_class) ||
                (node.respond_to?(:nodelist) && contains_tag_in_nodelist?(node.nodelist, tag_class))
            when Tag
              # Tags with blocks
              check_tag_for_nested(node, tag_class)
            else
              false
            end
          end
        end

        def self.check_tag_for_nested(tag, tag_class)
          # Check various block-holding tags
          [:@for_block, :@else_block, :@body, :@consequent, :@alternative].each do |ivar|
            if tag.instance_variable_defined?(ivar)
              block = tag.instance_variable_get(ivar)
              return true if contains_tag?(block, tag_class)
            end
          end

          # Check If tag's blocks array
          if tag.respond_to?(:blocks)
            tag.blocks.each do |block|
              if block.respond_to?(:attachment)
                return true if contains_tag?(block.attachment, tag_class)
              end
            end
          end

          false
        end

        def self.contains_tag_in_nodelist?(nodelist, tag_class)
          return false if nodelist.nil?
          nodelist.any? { |n| n.is_a?(tag_class) || (n.is_a?(Tag) && check_tag_for_nested(n, tag_class)) }
        end

        # Check if the loop body accesses forloop variable
        def self.uses_forloop_var?(body)
          return false if body.nil?
          nodelist = body.nodelist
          return false if nodelist.nil?

          nodelist.any? do |node|
            case node
            when Variable
              # Check if variable references forloop
              lookup = node.name
              if lookup.is_a?(VariableLookup)
                return true if lookup.name == 'forloop'
              end
              false
            when Tag
              # Recursively check tag bodies and conditions
              check_tag_for_forloop(node)
            else
              false
            end
          end
        end

        def self.check_tag_for_forloop(tag)
          # Check block bodies
          [:@for_block, :@else_block, :@body, :@consequent, :@alternative].each do |ivar|
            if tag.instance_variable_defined?(ivar)
              block = tag.instance_variable_get(ivar)
              return true if uses_forloop_var?(block)
            end
          end

          # Check If/Unless/Case conditions
          if tag.respond_to?(:blocks)
            tag.blocks.each do |block|
              # Check condition expressions
              if block.respond_to?(:left) && variable_references_forloop?(block.left)
                return true
              end
              if block.respond_to?(:right) && variable_references_forloop?(block.right)
                return true
              end
              # Check block attachment (body)
              if block.respond_to?(:attachment)
                return true if uses_forloop_var?(block.attachment)
              end
            end
          end

          false
        end

        # Check if an expression references forloop variable
        def self.variable_references_forloop?(expr)
          case expr
          when VariableLookup
            expr.name == 'forloop'
          when Variable
            expr.name.is_a?(VariableLookup) && expr.name.name == 'forloop'
          else
            false
          end
        end

        # Detect which forloop properties are used (for potential future optimization)
        # Returns Set of property names like 'index', 'first', 'last', etc.
        def self.detect_forloop_properties(body)
          props = Set.new
          collect_forloop_properties(body, props)
          props
        end

        def self.collect_forloop_properties(body, props)
          return if body.nil?
          nodelist = body.nodelist
          return if nodelist.nil?

          nodelist.each do |node|
            case node
            when Variable
              collect_forloop_from_variable(node, props)
            when Tag
              collect_forloop_from_tag(node, props)
            end
          end
        end

        def self.collect_forloop_from_variable(var, props)
          lookup = var.name
          if lookup.is_a?(VariableLookup) && lookup.name == 'forloop'
            lookup.lookups.each do |prop|
              props << prop if prop.is_a?(String)
            end
          end
        end

        def self.collect_forloop_from_tag(tag, props)
          # Check block bodies
          [:@for_block, :@else_block, :@body, :@consequent, :@alternative].each do |ivar|
            if tag.instance_variable_defined?(ivar)
              collect_forloop_properties(tag.instance_variable_get(ivar), props)
            end
          end

          # Check conditions
          if tag.respond_to?(:blocks)
            tag.blocks.each do |block|
              collect_forloop_from_condition(block, props) if block.respond_to?(:left)
              collect_forloop_properties(block.attachment, props) if block.respond_to?(:attachment)
            end
          end
        end

        def self.collect_forloop_from_condition(condition, props)
          [condition.left, condition.right].compact.each do |expr|
            if expr.is_a?(VariableLookup) && expr.name == 'forloop'
              expr.lookups.each do |prop|
                props << prop if prop.is_a?(String)
              end
            end
          end
          # Check child conditions
          collect_forloop_from_condition(condition.child_condition, props) if condition.respond_to?(:child_condition) && condition.child_condition
        end
      end
    end
  end
end
