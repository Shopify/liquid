---
title: downcase
description: Liquid filter that converts a string to lowercase.
---

Makes each character in a string lowercase. It has no effect on strings which are already all lowercase.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Parker Moore" | downcase }}
{{ "apple" | downcase }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Parker Moore" | downcase }}
{{ "apple" | downcase }}
```
