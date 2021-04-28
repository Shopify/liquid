---
title: floor
description: Liquid filter that returns the floor of a number by rounding down to the nearest integer.
---

Rounds an input down to the nearest whole number. Liquid tries to convert the input to a number before the filter is applied.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 1.2 | floor }}
{{ 2.0 | floor }}
{{ 183.357 | floor }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 1.2 | floor }}
{{ 2.0 | floor }}
{{ 183.357 | floor }}
```

Here the input value is a string:

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "3.5" | floor }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "3.5" | floor }}
```
