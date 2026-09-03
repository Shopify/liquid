# Recording and replaying renders

`Liquid::TemplateRecorder` captures successful template renders so they can be
replayed without the application's file system or Drop implementations.
Recording does not wrap or replace assigns, so the recorded render has the same
semantics as a normal render.

```ruby
Liquid::TemplateRecorder.record("render.json") do
  template = Liquid::Template.parse(source)
  template.render!(assigns)
end

replayer = Liquid::TemplateRecorder.replay_from("render.json", mode: :verify)
replayer.render # raises if the output changed
```

A recording contains the root template, every parsed partial, partial contents,
plain Hash/Array values resolved by the template, properties actually read from `Liquid::Drop` objects,
filter-call diagnostics, engine options, and the rendered output. Drop instance
variables are never inspected. An unsupported Ruby object raises
`Liquid::TemplateRecorder::SerializationError` rather than silently producing a
recording that cannot be replayed.

## Storage formats

A `.json` destination is written atomically after the recording block succeeds.
It contains a session with every render performed by the block.

A `.jsonl` destination is append-only. Each successful top-level render is one
compact, self-contained JSON line. This is the recommended format for production
sampling: a process failure can lose at most the render being written, writers
are serialized with `flock`, and a recording can be replayed by index.

A destination may instead be any writer object responding to `write(record)`. The
writer receives one self-contained recording Hash per successful render. Liquid
does not own or close injected writers, so applications can publish records to
Kafka, object storage, or another transport without coupling that transport to
the recorder.
Pass `on_error:` to keep serialization or sink failures out of the render path;
the callback receives the error and should not raise.

```ruby
Liquid::TemplateRecorder.record(kafka_writer) do
  template.render!(assigns)
end
```

```ruby
Liquid::TemplateRecorder.replay_from("renders.jsonl")           # last render
Liquid::TemplateRecorder.replay_from("renders.jsonl", index: 0) # first render
Liquid::TemplateRecorder.records("renders.jsonl")               # inspect all
```

Compression is intentionally separate from the schema. In particular, one
long-lived compressed stream makes appending, recovery, and selecting a render
harder. Compress rotated `.jsonl` files with the storage system of your choice;
a future compressed writer can use one independent frame per record without a
schema change.

Recording sessions are thread-local. Nested sessions in the same thread are
rejected. Existing application register names and the one-argument
`FileSystem#read_template_file` API remain unchanged.

## Replay modes

* `:compute` runs filters normally. Pass application filters with
  `replayer.render(filters: MyFilters)`.
* `:strict` returns each exact recorded filter result and rejects a changed
  filter sequence. This can replay application-specific or nondeterministic
  filters without loading their implementations.
* `:verify` computes normally and raises when the final output differs.
