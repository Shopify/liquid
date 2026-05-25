# Proposal: Deferred `render` with `after`

## Summary

Add an optional `after` modifier to Liquid's `{% render %}` tag:

```liquid
{% render 'product-card' after, product: product %}
```

When `after` is present, Liquid does not render the partial inline. Instead, it emits a stable HTML placeholder marker into the output and records enough information on the current `Liquid::Context` to render the partial later. A new context API then renders all deferred partials, ideally as a stream of out-of-order HTML replacement patches.

This is inspired by Chrome's Declarative Partial Updates proposal: https://developer.chrome.com/blog/declarative-partial-updates. The browser-side idea is to let HTML declare patch targets and stream their replacement content later, enabling the initial shell to be sent quickly while slower islands arrive when ready.

For Liquid, the equivalent is server-side syntax for declaring that a snippet can be delayed without changing template structure.

## Motivation

Liquid templates often have a mix of cheap layout work and expensive isolated snippets. Today, an expensive snippet blocks all subsequent output because `{% render %}` is synchronous and inline.

`render after` would allow templates to produce the main document quickly, reserve exact DOM locations for deferred snippets, and render those snippets later using the same Liquid render semantics.

Example use cases:

- Product recommendations below the fold.
- Expensive merchandising or personalization blocks.
- Analytics or SEO metadata fragments that can be patched into known locations.
- App blocks where the outer page shell should not wait on the block.

## Goals

- Add a small, Liquid-native API for deferring isolated snippet rendering.
- Preserve existing `{% render %}` isolation semantics.
- Emit processing-instruction placeholders that can be targeted by a later replacement patch.
- Store deferred render work in `Liquid::Context`.
- Add a context method to flush/enumerate/render deferred work.
- Keep the first prototype simple and non-streaming, while shaping the API so true streaming can be added later.

## Non-goals

- Implement browser support for Declarative Partial Updates.
- Require JavaScript for the Liquid-side primitive.
- Make arbitrary tags asynchronous.
- Allow deferred snippets to mutate the parent scope after the placeholder is emitted.
- Solve scheduling, prioritization, cancellation, or parallel execution in the first prototype.

## Syntax

The proposed syntax is:

```liquid
{% render 'snippet' after %}
{% render 'snippet' after, product: product %}
{% render 'snippet' after with product as item %}
{% render 'snippet' after for products as product %}
```

`after` is a render modifier with no value. It is intentionally boolean and reserved in this position.

The prototype supports bare `after` immediately after the rendered template name, because it reads like a render modifier rather than data passed into the snippet. `after: value` remains a normal named argument passed to the snippet.

## Output shape

When a deferred render is encountered, Liquid emits a Chrome-style processing-instruction placeholder marker with a unique id:

```html
<?marker name="liquid-after-1">
```

Later, flushing the deferred renders produces replacement patches. The target shape should be compatible with the direction of Declarative Partial Updates. For example:

```html
<template for="liquid-after-1">
  ...rendered snippet HTML...
</template>
```

The exact patch attribute names should track the platform proposal as it evolves. Until browser APIs stabilize, Liquid can expose a server-side patch format behind a small formatter object.

For the prototype, the replacement payload is a concatenated HTML patch string:

```ruby
context.render_after_tags
# => "<template for=...>...</template>"
```

## Semantics

### Evaluation timing

When `{% render 'snippet' after ... %}` is encountered:

1. Liquid evaluates the snippet name expression.
2. Liquid evaluates the `with` / `for` expression, if present.
3. Liquid evaluates all named render arguments.
4. Liquid records a deferred render job containing the evaluated values and render metadata.
5. Liquid emits a placeholder marker.

This means deferred renders capture values at enqueue time, not flush time. That avoids surprising behavior when variables change later in the template.

### Isolation

Deferred render jobs should use the same isolation semantics as normal `{% render %}`:

- The snippet receives only explicitly-passed variables plus globals/environments available to render today.
- Variables assigned inside the snippet do not leak into the parent template.
- The `include` tag remains disabled inside rendered snippets.

### Ordering

The queue is FIFO by default. Placeholder ids are monotonically increasing per context render:

```html
<?marker name="liquid-after-1">
<?marker name="liquid-after-2">
```

The streaming API may later render jobs as they become ready, but the prototype can preserve source order.

### Error handling

Deferred renders should use Liquid's existing error handling through `Context#handle_error` and `exception_renderer`.

Open question: if an error occurs while flushing deferred renders after the main template was already sent, should the replacement patch contain the rendered error string, an empty patch, or an out-of-band error? The prototype should match inline render behavior and place the rendered error into the patch body.

## Proposed API

Add queue APIs to `Liquid::Context`:

```ruby
context.enqueue_after_render(job) # internal
context.after_render_jobs         # inspection/testing
context.render_after_tags         # prototype: returns a string of patches
context.render_after_tags_to_output_buffer(output) # streaming-ready shape
```

Possible streaming-oriented API:

```ruby
context.each_after_render_patch do |patch|
  response.write(patch)
end
```

or:

```ruby
context.render_after_tags_to_output_buffer(response_stream)
```

The first implementation may buffer each snippet internally. The API should still write to an output object so callers can later stream each completed patch without changing template code.

## Example

Template:

```liquid
<h1>{{ product.title }}</h1>

{% render 'price', product: product %}

<section>
  {% render 'recommendations' after, product: product %}
</section>
```

Initial output:

```html
<h1>Snowboard</h1>

<span>$699.00</span>

<section>
  <?marker name="liquid-after-1">
</section>
```

Deferred patch output:

```html
<template for="liquid-after-1">
  <ul class="recommendations">...</ul>
</template>
```

A Rack-like integration could do:

```ruby
context = Liquid::Context.build(...)
body = template.render!(context)
response.write(body)
context.render_after_tags_to_output_buffer(response)
```

The prototype can buffer `body` first. A production integration would stream `body` immediately, then stream each deferred patch as soon as it completes.

## Compatibility

Existing templates are unaffected unless they use bare `after` immediately after the rendered template name.

Because bare `after` becomes reserved syntax for the render tag in that position, this could conflict with unusual templates that currently rely on that token being ignored. Snippets currently receiving an `after:` keyword argument continue to work:

```liquid
{% render 'divider', after: 'label' %}
```

This proposal only reserves bare `after`; `after: value` continues to be passed as a normal snippet attribute. That minimizes compatibility risk.
