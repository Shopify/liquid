---
title: ceil
description: Liquid filter that returns the ceiling of a number by rounding up to the nearest integer.
---

Rounds an input up to the nearest whole number. Liquid tries to convert the input to a number before the filter is applied.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 1.2 | ceil }}
{{ 2.0 | ceil }}
{{ 183.357 | ceil }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 1.2 | ceil }}
{{ 2.0 | ceil }}
{{ 183.357 | ceil }}
```

Here the input value is a string:

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "3.5" | ceil }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "3.5" | ceil }}
```
