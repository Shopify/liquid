# frozen_string_literal: true

require 'English'
require "digest/sha2"
require "json"
require "securerandom"
require "tempfile"
require "time"

module Liquid
  # Records complete Liquid renders without changing the objects being rendered.
  # A .json file contains one session; a .jsonl file is an append-only sequence
  # of independently replayable renders.
  class TemplateRecorder
    FORMAT = "liquid-render"
    SCHEMA_VERSION = 1
    REGISTER_KEY = :__liquid_template_recorder
    REPLAYER_REGISTER_KEY = :__liquid_template_recorder_replayer

    class Error < StandardError; end
    class ReplayError < Error; end
    class SerializationError < Error; end

    class << self
      def record(destination, on_error: nil)
        raise ArgumentError, "a block is required" unless block_given?

        previous_session = current
        raise Error, "nested recording sessions are not supported" if previous_session

        session = Session.new(destination, on_error: on_error)
        Thread.current[thread_key] = session
        yield
      ensure
        if session
          Thread.current[thread_key] = previous_session
          session.close if $ERROR_INFO.nil?
        end
      end

      def current
        Thread.current[thread_key]
      end

      def replay_from(path, mode: :compute, index: -1)
        records = Store.read(path)
        raise ReplayError, "recording contains no renders" if records.empty?

        record = records.fetch(index)
        Replayer.new(record, mode: mode)
      rescue IndexError
        raise ReplayError, "render index #{index} does not exist"
      end

      def records(path)
        Store.read(path)
      end

      private

      def thread_key
        :__liquid_template_recorder_session
      end
    end

    class Session
      def initialize(destination, on_error:)
        @path = destination.to_s if destination.is_a?(String) || destination.respond_to?(:to_path)
        @writer = destination unless @path
        @on_error = on_error
        @records = []
        @active = nil
        @pending_files = {}
      end

      def begin_render(template, _assigns, context)
        if @active
          @active.add_template(template)
          @active.nesting += 1
          return @active
        end

        @active = Render.new(template, context)
        @pending_files.each { |path, source| @active.emit_file_read(path, source) }
        @pending_files.clear
        @active
      end

      def emit_file_read(path, source)
        if @active
          @active.emit_file_read(path, source)
        else
          @pending_files[path.to_s] = source
        end
      end

      def emit_variable_output(output)
        @active&.emit_variable_output(output)
      end

      def begin_tag_render(node, context)
        @active&.begin_tag_render(node, context)
      end

      def finish_tag_render(call, output)
        @active&.finish_tag_render(call, output)
      end

      def finish_render(render, output, context, success:)
        return unless render.equal?(@active)

        if render.nesting.positive?
          render.nesting -= 1
          return
        end

        if success
          begin
            record = render.finish(output, context)
            if @writer
              @writer.write(record)
            elsif Store.jsonl?(@path)
              Store.append(@path, record)
            else
              @records << record
            end
          rescue => error
            handle_error(error)
          end
        end
        @active = nil
      end

      def close
        return if @writer || Store.jsonl?(@path)

        Store.write_session(@path, @records)
      rescue => error
        handle_error(error)
      end

      private

      def handle_error(error)
        raise error unless @on_error

        @on_error.call(error)
      end
    end

    class Render
      attr_accessor :nesting

      def initialize(template, _context)
        @nesting = 0
        @templates = []
        @files = {}
        @filter_calls = []
        @tag_calls = []
        @tag_render_depth = 0
        @variables = {}
        @variable_outputs = []
        @drop_values = {}
        @bindings = {}.compare_by_identity
        @root_template = template
        add_template(template)
      end

      def add_template(template)
        source = template.instance_variable_get(:@template_recorder_source)
        return unless source

        entrypoint = template.name
        digest = Digest::SHA256.hexdigest(source)
        return if @templates.any? { |item| item["sha256"] == digest && item["entrypoint"] == entrypoint }

        @templates << { "source" => source, "entrypoint" => entrypoint, "sha256" => digest }
      end

      def emit_variable_output(output)
        return if @tag_render_depth.positive?

        @variable_outputs << output
      end

      def begin_tag_render(node, context)
        name = context.environment.tags.key(node.class)
        return unless name

        @tag_render_depth += 1
        return :nested if @tag_render_depth > 1

        call = { "name" => name.to_s, "output" => nil }
        @tag_calls << call
        call
      end

      def finish_tag_render(call, output)
        return unless call

        @tag_render_depth -= 1
        call["output"] = output unless call == :nested
      end

      def emit_variable_read(name, value)
        path = [name.to_s]
        @variables[name.to_s] = serialize(value, path, bind: true)
      rescue SerializationError
        # Unsupported values must not affect the render being observed.
      end

      def emit_drop_read(drop, key, value)
        base = @bindings[drop]
        return unless base

        path = base + [key.to_s]
        set_path(@drop_values, path, serialize(value, path, bind: true))
      rescue SerializationError
        # Unsupported values must not affect the render being observed.
      end

      def emit_file_read(path, source)
        @files[path.to_s] = source.to_s
      end

      def emit_filter_call(name, input, arguments, output)
        return if @tag_render_depth.positive?

        @filter_calls << {
          "name" => name.to_s,
          "input" => serialize(input, ["filters", @filter_calls.length, "input"]),
          "arguments" => serialize(arguments, ["filters", @filter_calls.length, "arguments"]),
          "output" => serialize(output, ["filters", @filter_calls.length, "output"]),
        }
      rescue SerializationError
        # Filter diagnostics must never make an otherwise replayable render fail.
      end

      def finish(output, context)
        variables = deep_merge(@variables, @drop_values)
        source = @root_template.instance_variable_get(:@template_recorder_source)
        raise Error, "the rendered template was parsed outside the recording block" unless source

        {
          "format" => FORMAT,
          "schema_version" => SCHEMA_VERSION,
          "id" => SecureRandom.uuid,
          "recorded_at" => Time.now.utc.iso8601,
          "engine" => {
            "liquid_version" => Liquid::VERSION,
            "ruby_version" => RUBY_VERSION,
            "strict_variables" => !!context.strict_variables,
            "strict_filters" => !!context.strict_filters,
          },
          "template" => @templates.first,
          "templates" => @templates,
          "assigns" => variables,
          "variable_outputs" => @variable_outputs,
          "file_system" => @files,
          "filter_calls" => @filter_calls,
          "tag_calls" => @tag_calls,
          "output" => output.to_s,
        }
      end

      private

      def serialize(value, path, seen = {}.compare_by_identity, bind: false)
        case value
        when nil, true, false, String, Integer, Float
          value
        when Symbol
          value.to_s
        when Liquid::Drop
          @bindings[value] ||= path if bind
          existing = value_at(@drop_values, @bindings[value])
          existing || {}
        when Hash
          raise SerializationError, "circular value at #{format_path(path)}" if seen.key?(value)

          seen[value] = true
          result = value.each_with_object({}) do |(key, child), hash|
            string_key = key.to_s
            hash[string_key] = serialize(child, path + [string_key], seen, bind: bind)
          end
          seen.delete(value)
          result
        when Array
          raise SerializationError, "circular value at #{format_path(path)}" if seen.key?(value)

          seen[value] = true
          result = value.each_with_index.map { |child, index| serialize(child, path + [index], seen, bind: bind) }
          seen.delete(value)
          result
        else
          raise SerializationError, "cannot record #{value.class} at #{format_path(path)}"
        end
      end

      def set_path(root, path, value)
        return root.replace(value) if path.empty? && value.is_a?(Hash)

        cursor = root
        path.each_with_index do |segment, index|
          last = index == path.length - 1
          if segment.is_a?(Integer)
            break unless cursor.is_a?(Array)

          end
          cursor[segment] = last ? value : (cursor[segment] ||= container_for(path[index + 1]))
          cursor = cursor[segment] unless last
        end
      end

      def value_at(root, path)
        return unless path

        path.reduce(root) { |value, segment| value.respond_to?(:[]) ? value[segment] : nil }
      end

      def container_for(segment)
        segment.is_a?(Integer) ? [] : {}
      end

      def deep_merge(left, right)
        return right unless left.is_a?(Hash) && right.is_a?(Hash)

        left.merge(right) { |_key, a, b| deep_merge(a, b) }
      end

      def format_path(path)
        path.empty? ? "<root>" : path.join(".")
      end
    end

    class Store
      class << self
        def jsonl?(path)
          path.end_with?(".jsonl")
        end

        def append(path, record)
          line = JSON.generate(record) << "\n"
          File.open(path, File::WRONLY | File::CREAT | File::APPEND, 0o600) do |file|
            file.flock(File::LOCK_EX)
            file.write(line)
            file.flush
          end
        end

        def write_session(path, records)
          payload = JSON.pretty_generate(
            "format" => "liquid-recording-session",
            "schema_version" => SCHEMA_VERSION,
            "renders" => records,
          ) << "\n"
          directory = File.dirname(File.expand_path(path))
          Tempfile.create([".liquid-recording", ".tmp"], directory, mode: File::RDWR, perm: 0o600) do |file|
            file.write(payload)
            file.flush
            file.fsync
            File.rename(file.path, path)
          end
        end

        def read(path)
          content = File.binread(path)
          records = if jsonl?(path)
            read_jsonl(content)
          else
            parsed = JSON.parse(content)
            parsed["renders"] || [parsed]
          end
          records.each { |record| validate!(record) }
          records
        rescue Errno::ENOENT
          raise ReplayError, "recording file not found: #{path}"
        rescue JSON::ParserError => error
          raise ReplayError, "invalid recording JSON: #{error.message}"
        end

        def read_jsonl(content)
          lines = content.lines
          lines.filter_map.with_index do |line, index|
            next if line.strip.empty?

            JSON.parse(line)
          rescue JSON::ParserError
            last_truncated_line = index == lines.length - 1 && !content.end_with?("\n")
            raise unless last_truncated_line
          end
        end

        def validate!(record)
          raise ReplayError, "unsupported recording format" unless record["format"] == FORMAT
          raise ReplayError, "unsupported schema version #{record["schema_version"].inspect}" unless record["schema_version"] == SCHEMA_VERSION

          ['template', 'assigns', 'file_system', 'output'].each do |key|
            raise ReplayError, "recording is missing #{key}" unless record.key?(key)
          end
          template = record["template"]
          expected = Digest::SHA256.hexdigest(template.fetch("source"))
          raise ReplayError, "template checksum does not match" unless template["sha256"] == expected
        rescue KeyError, TypeError => error
          raise ReplayError, "invalid recording schema: #{error.message}"
        end
      end
    end

    class MemoryFileSystem
      def initialize(files)
        @files = files
      end

      def read_template_file(path)
        @files.fetch(path.to_s) { raise FileSystemError, "No such template '#{path}'" }
      end
    end

    class Replayer
      def initialize(record, mode: :compute, environment: nil)
        @record = record
        @mode = mode.to_sym
        @environment = environment
        unless [:compute, :strict, :verify].include?(@mode)
          raise ReplayError, "mode must be :compute, :strict, or :verify"
        end
      end

      def render(to: nil, filters: nil)
        @filter_index = 0
        @tag_index = 0
        @variable_index = 0
        parse_options = {}
        parse_options[:environment] = strict_environment if @mode == :strict
        template = Liquid::Template.parse(@record.dig("template", "source"), parse_options)
        registers = { file_system: MemoryFileSystem.new(@record["file_system"]) }
        registers[REPLAYER_REGISTER_KEY] = self if @mode == :strict && @record.key?("variable_outputs")
        options = {
          registers: registers,
          strict_variables: @record.dig("engine", "strict_variables"),
          strict_filters: @record.dig("engine", "strict_filters"),
        }
        options[:filters] = filters if filters
        output = template.render!(@record["assigns"], options)
        if @mode == :strict
          verify_filter_count! unless @record.key?("variable_outputs")
          verify_tag_count!
          verify_variable_count!
        end
        if [:strict, :verify].include?(@mode) && output != @record["output"]
          raise ReplayError, "replayed output does not match the recording"
        end

        File.binwrite(to, output) if to
        output
      end

      def replay_filter(name)
        call = @record["filter_calls"].fetch(@filter_index) do
          raise ReplayError, "unexpected filter call #{name}"
        end
        if call["name"] != name.to_s
          raise ReplayError, "expected filter #{call["name"]}, got #{name}"
        end

        @filter_index += 1
        JSON.parse(JSON.generate(call["output"]))
      end

      def replay_variable
        value = @record.fetch("variable_outputs").fetch(@variable_index) do
          raise ReplayError, "unexpected variable render"
        end
        @variable_index += 1
        value
      end

      def replay_tag(name)
        call = @record.fetch("tag_calls", []).fetch(@tag_index) do
          raise ReplayError, "unexpected tag call #{name}"
        end
        if call["name"] != name.to_s
          raise ReplayError, "expected tag #{call["name"]}, got #{name}"
        end

        @tag_index += 1
        call["output"]
      end

      def recorded_output
        @record["output"]
      end

      def templates
        @record["templates"]
      end

      private

      def strict_environment
        replayer = self
        strainer = Class.new(Liquid::StrainerTemplate) do
          define_method(:invoke) do |name, *_args|
            replayer.replay_filter(name)
          end
        end
        tags = (@environment || Liquid::Environment.default).tags.dup
        tags&.each do |name, tag_class|
          tags[name] = replay_tag_class(tag_class, name)
        end
        Liquid::Environment.build(tags: tags) do |environment|
          environment.strainer_template = strainer
        end
      end

      def replay_tag_class(tag_class, name)
        replayer = self
        Class.new(tag_class) do
          define_method(:render_to_output_buffer) do |_context, output|
            output << replayer.replay_tag(name)
          end
        end
      end

      def verify_variable_count!
        return unless @record.key?("variable_outputs")

        expected = @record["variable_outputs"].length
        return if @variable_index == expected

        raise ReplayError, "expected #{expected} variable renders, got #{@variable_index}"
      end

      def verify_tag_count!
        expected = @record.fetch("tag_calls", []).length
        return if @tag_index == expected

        raise ReplayError, "expected #{expected} tag calls, got #{@tag_index}"
      end

      def verify_filter_count!
        expected = @record["filter_calls"].length
        return if @filter_index == expected

        raise ReplayError, "expected #{expected} filter calls, got #{@filter_index}"
      end
    end
  end
end
