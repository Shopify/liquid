---
title: abs
description: Liquid filter that returns the absolute value of a number.
redirect_from: /filters/
---

Returns the absolute value of a number.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ -17 | abs }}
{{ 4 | abs }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ -17 | abs }}
{{ 4 | abs }}
```

`abs` will also work on a string that only contains a number.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "-19.86" | abs }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "-19.86" | abs }}
```
