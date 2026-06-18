# Liquid Template Recorder Implementation Plan

## Overview

This document outlines the comprehensive implementation plan for the Liquid Template Recorder, a system for hermetic recording and replay of Liquid template renders. The implementation will capture exactly what a template reads and uses during rendering, then write a single JSON file containing only scalars, arrays, and maps sufficient to re-run the template without Drop implementations or external file system access.

## Project Structure

```
lib/liquid/
├── template_recorder.rb          # Main TemplateRecorder class and API
├── template_recorder/
│   ├── recorder.rb               # Core recording logic and event handling  
│   ├── replayer.rb               # Replay engine with multiple modes
│   ├── memory_file_system.rb     # In-memory file system for replay
│   ├── binding_tracker.rb        # Object ID to path binding management
│   ├── event_log.rb              # Event collection and processing
│   └── json_schema.rb            # JSON serialization and validation
├── drop.rb                       # Modified: add recording hook
├── strainer_template.rb          # Modified: add filter recording
├── tags/for.rb                   # Modified: add loop recording hooks
└── file_system.rb                # Modified: add file read recording

test/integration/
├── template_recorder_test.rb     # Main recorder integration tests
└── fixtures/
    └── recorder/                 # Test templates and expected recordings
```

## Phase 1: Core Recorder Infrastructure

### 1.1 TemplateRecorder Main API (`lib/liquid/template_recorder.rb`)

```ruby
module Liquid
  class TemplateRecorder
    # Primary recording API
    def self.record(filename, &block)
    def self.replay_from(filename, mode: :compute)
    
    # Internal factory methods
    def self.create_recorder
    def self.create_replayer(data, mode)
  end
end
```

**Key Responsibilities:**
- Provide top-level recording and replay API
- Manage thread-local recorder instance during recording block
- Handle file I/O for JSON recording files
- Coordinate between recorder and replayer components

**Implementation Details:**
- Use `Thread.current[:liquid_recorder]` for file system hooks
- Wrap template rendering with recorder injection via `context.registers[:recorder]`
- Ensure single JSON file output after block completion
- Handle multiple parse/render cycles within single recording block

### 1.2 Core Recorder (`lib/liquid/template_recorder/recorder.rb`)

```ruby
class Liquid::TemplateRecorder::Recorder
  def initialize
    @events = EventLog.new
    @binding_tracker = BindingTracker.new
    @file_reads = {}
    @template_info = {}
  end
  
  # Event recording methods
  def emit_drop_read(drop_object, method_name, result)
  def emit_filter_call(name, input, args, output, location = nil)
  def emit_file_read(path, content)
  def for_enter(collection_expr)
  def for_item(index, item)
  def for_exit
  
  # Finalization
  def finalize_recording
end
```

**Key Responsibilities:**
- Collect all recording events during template execution
- Maintain object ID to variable path bindings
- Track loop nesting and item binding
- Generate minimal assigns tree from recorded events
- Serialize final JSON with stable ordering

**Implementation Details:**
- Use `object_id` mapping to track Drop instances to variable paths
- Handle nested loops with stack-based item binding
- Only store scalars in final JSON; use objects transiently for path building
- Coalesce duplicate reads; last value wins for conflicts

### 1.3 Binding Tracker (`lib/liquid/template_recorder/binding_tracker.rb`)

```ruby
class Liquid::TemplateRecorder::BindingTracker
  def initialize
    @object_bindings = {}  # object_id => variable_path
    @loop_stack = []       # current loop context stack
  end
  
  def bind_root_object(object, path)
  def bind_loop_item(object, path)
  def resolve_binding_path(object)
  def enter_loop(collection_path)
  def exit_loop
end
```

**Key Responsibilities:**
- Map object IDs to their canonical variable paths
- Handle nested loop item binding
- Resolve property access paths (e.g., `product.variants[1].name`)
- Maintain loop context stack for nested iterations

## Phase 2: Integration Hooks

### 2.1 Drop Recording Hook (`lib/liquid/drop.rb`)

**Modification to `invoke_drop` method:**

```ruby
def invoke_drop(method_or_key)
  result = if self.class.invokable?(method_or_key)
    send(method_or_key)
  else
    liquid_method_missing(method_or_key)
  end
  
  # Recording hook - only active when recorder present
  if @context && (recorder = @context.registers[:recorder])
    recorder.emit_drop_read(self, method_or_key, result)
  end
  
  result
end
```

**Key Considerations:**
- Zero overhead when no recorder present (single hash lookup)
- Access to `@context` for recorder retrieval  
- Called after result computation to capture actual values
- Handles both successful method calls and `liquid_method_missing`

### 2.2 Filter Recording Hook (`lib/liquid/strainer_template.rb`)

**Modification to `invoke` method:**

```ruby
def invoke(method, *args)
  result = if self.class.invokable?(method)
    send(method, *args)
  elsif @context.strict_filters
    raise Liquid::UndefinedFilter, "undefined filter #{method}"
  else
    args.first
  end
  
  # Recording hook
  if (recorder = @context.registers[:recorder])
    recorder.emit_filter_call(method, args.first, args[1..-1], result)
  end
  
  result
rescue ::ArgumentError => e
  raise Liquid::ArgumentError, e.message, e.backtrace
end
```

**Key Considerations:**
- Record input, arguments, and output for each filter call
- Capture location information when available
- Handle filter errors appropriately
- Sequential filter log for strict replay mode

### 2.3 For Loop Recording Hooks (`lib/liquid/tags/for.rb`)

**Modifications to `render_segment` method:**

```ruby
def render_segment(context, output, segment)
  # Recording hook - loop enter
  if (recorder = context.registers[:recorder])
    recorder.for_enter(@collection_name.to_s)
  end
  
  for_stack = context.registers[:for_stack] ||= []
  length    = segment.length

  context.stack do
    loop_vars = Liquid::ForloopDrop.new(@name, length, for_stack[-1])
    for_stack.push(loop_vars)

    begin
      context['forloop'] = loop_vars

      segment.each_with_index do |item, index|
        # Recording hook - item binding
        if (recorder = context.registers[:recorder])
          recorder.for_item(index, item)
        end
        
        context[@variable_name] = item
        @for_block.render_to_output_buffer(context, output)
        loop_vars.send(:increment!)

        next unless context.interrupt?
        interrupt = context.pop_interrupt
        break if interrupt.is_a?(BreakInterrupt)
        next if interrupt.is_a?(ContinueInterrupt)
      end
    ensure
      for_stack.pop
      
      # Recording hook - loop exit
      if (recorder = context.registers[:recorder])
        recorder.for_exit
      end
    end
  end

  output
end
```

**Key Considerations:**
- Hook loop enter/exit for proper nesting tracking
- Bind each loop item to array index position
- Handle nested loops with proper stack management
- Maintain existing loop interrupt behavior

### 2.4 File System Recording Hook (`lib/liquid/file_system.rb`)

**Modification to `LocalFileSystem#read_template_file`:**

```ruby
def read_template_file(template_path)
  full_path = full_path(template_path)
  raise FileSystemError, "No such template '#{template_path}'" unless File.exist?(full_path)

  content = File.read(full_path)
  
  # Recording hook via thread-local
  if (recorder = Thread.current[:liquid_recorder])
    recorder.emit_file_read(template_path, content)
  end
  
  content
end
```

**Key Considerations:**
- Use thread-local access since Context not available
- Record template path and full content
- Maintain existing error handling behavior
- Thread-local set/unset managed by main TemplateRecorder

## Phase 3: Replay System

### 3.1 Replayer Engine (`lib/liquid/template_recorder/replayer.rb`)

```ruby
class Liquid::TemplateRecorder::Replayer
  def initialize(recording_data, mode = :compute)
    @data = recording_data
    @mode = mode
    @memory_fs = MemoryFileSystem.new(@data['file_system'])
    @filter_index = 0
  end
  
  def render(to: nil)
  
  private
  
  def setup_context
  def create_strict_strainer if @mode == :strict
  def validate_engine_compatibility
end
```

**Replay Modes:**
- `:compute` - Use recorded data with current Liquid engine and filters
- `:strict` - Replay recorded filter outputs in sequence
- `:verify` - Compute and compare against recorded outputs

**Key Responsibilities:**
- Parse recorded template source
- Build assigns from recorded variable tree
- Configure MemoryFileSystem with recorded files
- Handle mode-specific filter behavior
- Validate engine compatibility and warn on version mismatches

### 3.2 Memory File System (`lib/liquid/template_recorder/memory_file_system.rb`)

```ruby
class Liquid::TemplateRecorder::MemoryFileSystem
  def initialize(file_contents_hash)
    @files = file_contents_hash
  end
  
  def read_template_file(template_path)
    @files[template_path] or raise FileSystemError, "No such template '#{template_path}'"
  end
end
```

**Key Responsibilities:**
- Serve recorded file contents during replay
- Maintain same interface as LocalFileSystem
- Raise appropriate errors for missing files

### 3.3 Event Log (`lib/liquid/template_recorder/event_log.rb`)

```ruby
class Liquid::TemplateRecorder::EventLog
  def initialize
    @drop_reads = []
    @filter_calls = []
    @loop_events = []
  end
  
  def add_drop_read(event)
  def add_filter_call(event)  
  def add_loop_event(event)
  
  def finalize_to_assigns_tree
end
```

**Key Responsibilities:**
- Collect all events during recording
- Process events into minimal assigns tree
- Handle event deduplication and conflict resolution
- Generate arrays-of-maps for loop data

## Phase 4: JSON Schema and Serialization

### 4.1 JSON Schema Definition (`lib/liquid/template_recorder/json_schema.rb`)

```ruby
{
  "schema_version": 1,
  "engine": {
    "liquid_version": "x.y.z",
    "ruby_version": "3.x",
    "settings": {
      "strict_variables": false,
      "strict_filters": false,
      "error_mode": "lax"
    }
  },
  "template": {
    "source": "template source code",
    "entrypoint": "templates/product.liquid",
    "sha256": "content hash"
  },
  "data": {
    "variables": {
      "product": {
        "title": "Product Name",
        "variants": [
          { "name": "Variant 1", "price": 29.99 },
          { "name": "Variant 2", "price": 39.99 }
        ]
      }
    }
  },
  "file_system": {
    "snippets/variant.liquid": "template content",
    "sections/product.liquid": "template content"
  },
  "filters": [
    {
      "name": "append",
      "input": "base string",
      "args": ["suffix"],
      "output": "base stringsuffix",
      "location": { "template": "product.liquid", "line": 10 }
    }
  ],
  "output": {
    "string": "final rendered output"
  },
  "metadata": {
    "timestamp": "2025-07-30T00:00:00Z",
    "recorder_version": 1
  }
}
```

**Validation Rules:**
- Only scalars, arrays, and maps in `data.variables`
- All file paths relative to template root
- Filter log maintains call order
- Schema version compatibility checking

### 4.2 Serialization Implementation

```ruby
class Liquid::TemplateRecorder::JsonSchema
  def self.serialize(recorder)
  def self.deserialize(json_string)
  def self.validate_schema(data)
  
  private
  
  def self.ensure_serializable(obj)
  def self.calculate_template_hash(source)
end
```

**Key Responsibilities:**
- Ensure only serializable types in output
- Generate stable, pretty-printed JSON
- Validate schema compliance
- Handle version compatibility

## Phase 5: Testing and Integration

### 5.1 ThemeRunner Integration

**Test Helper Methods:**

```ruby
def record_theme_test(test_name, filename = nil)
  filename ||= "/tmp/#{test_name.gsub('/', '_')}.json"
  Liquid::TemplateRecorder.record(filename) do
    ThemeRunner.new.run_one_test(test_name)
  end
  filename
end

def replay_and_compare(recording_file, mode = :compute)
  replayer = Liquid::TemplateRecorder.replay_from(recording_file, mode: mode)
  replayer.render
end
```

### 5.2 Test Coverage Plan

**Unit Tests:**
- TemplateRecorder API (record/replay)
- Recorder event collection
- BindingTracker object mapping  
- EventLog finalization
- JSON schema validation
- MemoryFileSystem behavior

**Integration Tests:**
- ThemeRunner recording/replay cycles
- Complex nested template scenarios
- Multiple loop nesting
- Filter chain recording
- Include/render tag behavior
- Error handling and edge cases

**Performance Tests:**
- Recording overhead measurement
- Memory usage during large template recording
- Replay performance vs original render
- JSON file size for complex templates

### 5.3 Edge Case Handling

**Complex Scenarios:**
- Deeply nested loops (variants.images.tags)
- Dynamic include paths
- Conditional filter chains
- Complex property access chains
- Mixed scalar/object property reads
- Loop variable shadowing
- Include/render with different file systems

**Error Conditions:**
- Invalid JSON schema
- Missing recorded files during replay
- Filter signature changes between record/replay
- Template parsing errors
- Memory/resource limit violations
- Version compatibility issues

## Phase 6: Documentation and Examples

### 6.1 API Documentation

- Comprehensive RDoc for all public methods
- Usage examples for common scenarios
- Mode comparison guide (compute vs strict vs verify)
- Performance characteristics documentation
- Troubleshooting guide for common issues

### 6.2 Example Usage

```ruby
# Simple recording
Liquid::TemplateRecorder.record("recording.json") do
  template = Liquid::Template.parse("Hello {{ name }}!")
  template.render("name" => "World")
end

# ThemeRunner integration
Liquid::TemplateRecorder.record("product.json") do
  ThemeRunner.new.run_one_test("dropify/product.liquid")
end

# Replay modes
replayer = Liquid::TemplateRecorder.replay_from("product.json", mode: :compute)
output = replayer.render

# CLI usage
ruby -rliquid -e 'puts Liquid::TemplateRecorder.replay_from(ARGV[0]).render' recording.json
```

## Implementation Timeline

**Phase 1 (Week 1-2): Core Infrastructure**
- TemplateRecorder main API
- Recorder class with event collection
- BindingTracker for object mapping
- Basic JSON schema

**Phase 2 (Week 2-3): Integration Hooks**
- Drop recording hook
- Filter recording hook  
- For loop recording hooks
- File system recording hook

**Phase 3 (Week 3-4): Replay System**
- Replayer engine with mode support
- MemoryFileSystem implementation
- Event log processing
- JSON deserialization

**Phase 4 (Week 4-5): Testing and Polish**
- Comprehensive test suite
- ThemeRunner integration testing
- Performance optimization
- Documentation completion

**Phase 5 (Week 5-6): Edge Cases and Validation**
- Complex scenario testing
- Error handling improvements
- Version compatibility
- Final integration testing

## Success Criteria

1. **Functional Requirements:**
   - Record and replay ThemeRunner tests with identical output
   - Handle complex nested loops and includes
   - Support all three replay modes (compute/strict/verify)
   - Generate human-readable, diffable JSON files

2. **Performance Requirements:**
   - <5% overhead when recording disabled
   - <20% overhead during active recording
   - Replay within 50% of original render time
   - JSON files <10x original template size

3. **Quality Requirements:**
   - 100% test coverage for core recorder functionality
   - Zero memory leaks during extended recording sessions
   - Graceful handling of all error conditions
   - Comprehensive documentation and examples

4. **Integration Requirements:**
   - Seamless ThemeRunner integration
   - CLI-friendly one-liner replay
   - Compatible with existing Liquid features
   - No breaking changes to existing APIs

This implementation plan provides a comprehensive roadmap for building the Liquid Template Recorder system with proper separation of concerns, thorough testing, and clear integration points.