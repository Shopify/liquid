---
title: round
description: Liquid filter that rounds a number to the nearest integer.
---

Rounds a number to the nearest integer or, if a number is passed as an argument, to that number of decimal places.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 1.2 | round }}
{{ 2.7 | round }}
{{ 183.357 | round: 2 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 1.2 | round }}
{{ 2.7 | round }}
{{ 183.357 | round: 2 }}
```
