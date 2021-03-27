---
title: plus
description: Liquid filter that adds one number to another number.
---

Adds a number to another number.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 4 | plus: 2 }}
{{ 16 | plus: 4 }}
{{ 183.357 | plus: 12 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 4 | plus: 2 }}
{{ 16 | plus: 4 }}
{{ 183.357 | plus: 12 }}
```
