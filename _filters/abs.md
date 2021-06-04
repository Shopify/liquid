---
title: abs
category: math
description: Liquid filter that returns the absolute value of a number.
---

Returns the absolute value of a number. `abs` will also work on a string that only contains a number.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ -17 | abs }}
{{ 4 | abs }}
{{ "-19.86" | abs }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ -17 | abs }}
{{ 4 | abs }}
{{ "-19.86" | abs }}
```
