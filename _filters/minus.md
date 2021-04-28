---
title: minus
description: Liquid filter that subtracts one number from another number.
---

Subtracts a number from another number.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 4 | minus: 2 }}
{{ 16 | minus: 4 }}
{{ 183.357 | minus: 12 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 4 | minus: 2 }}
{{ 16 | minus: 4 }}
{{ 183.357 | minus: 12 }}
```
