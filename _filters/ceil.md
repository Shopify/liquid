---
title: ceil
category: math
description: Liquid filter that returns the ceiling of a number by rounding up to the nearest integer.
---

Rounds an input up to the nearest whole number. `ceil` will also work on a string that only contains a number.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 1.2 | ceil }}
{{ 2.0 | ceil }}
{{ 183.357 | ceil }}
{{ "3.5" | ceil }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 1.2 | ceil }}
{{ 2.0 | ceil }}
{{ 183.357 | ceil }}
{{ "3.5" | ceil }}
```
