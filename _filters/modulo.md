---
title: modulo
description: Liquid filter that returns the remainder of a division operation.
---

Returns the remainder of a division operation.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 3 | modulo: 2 }}
{{ 24 | modulo: 7 }}
{{ 183.357 | modulo: 12 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 3 | modulo: 2 }}
{{ 24 | modulo: 7 }}
{{ 183.357 | modulo: 12 }}
```
