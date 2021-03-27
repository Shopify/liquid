---
title: floor
description: Liquid filter that returns the floor of a number by rounding down to the nearest integer.
---

Rounds an input down to the nearest whole number. `floor` will also work on a string that only contains a number.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 1.2 | floor }}
{{ 2.0 | floor }}
{{ 183.357 | floor }}
{{ "3.5" | floor }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 1.2 | floor }}
{{ 2.0 | floor }}
{{ 183.357 | floor }}
{{ "3.5" | floor }}
```
