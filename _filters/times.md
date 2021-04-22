---
title: times
description: Liquid filter that multiplies a number by another number.
---

Multiplies a number by another number.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 3 | times: 2 }}
{{ 24 | times: 7 }}
{{ 183.357 | times: 12 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 3 | times: 2 }}
{{ 24 | times: 7 }}
{{ 183.357 | times: 12 }}
```
