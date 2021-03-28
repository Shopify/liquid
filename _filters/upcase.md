---
title: upcase
category: string
description: Liquid filter that converts a string to uppercase.
---

Makes each character in a string uppercase. It has no effect on strings which are already all uppercase.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Parker Moore" | upcase }}
{{ "APPLE" | upcase }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Parker Moore" | upcase }}
{{ "APPLE" | upcase }}
```
