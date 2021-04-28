---
title: at_least
description: Liquid filter that limits a number to a minimum value.
version-badge: 4.0.1
---

Limits a number to a minimum value.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ 4 | at_least: 5 }}
{{ 4 | at_least: 3 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
5
4
```
