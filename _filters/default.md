---
title: default
description: Liquid filter that specifies a fallback in case a value doesn't exist.
---

Sets a default value for any variable with no assigned value. `default` will show its value if the input is `nil`, `false`, or empty.

In this example, `product_price` is not defined, so the default value is used.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ product_price | default: 2.99 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ product_price | default: 2.99 }}
```

In this example, `product_price` is defined, so the default value is not used.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign product_price = 4.99 %}
{{ product_price | default: 2.99 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign product_price = 4.99 %}
{{ product_price | default: 2.99 }}
```

In this example, `product_price` is empty, so the default value is used.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign product_price = "" %}
{{ product_price | default: 2.99 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign product_price = "" %}
{{ product_price | default: 2.99 }}
```

### Allowing `false` {%- include version-badge.html version="5.0.0" %}

To allow variables to return `false` instead of the default value, you can use the `allow_false` parameter.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign display_price = false %}
{{ display_price | default: true, allow_false: true }}
{% endraw %}
```

<p class="code-label">Output</p>
```text

false
```
