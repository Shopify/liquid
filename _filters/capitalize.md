---
title: capitalize
description: Liquid filter that capitalizes the first character of a string and downcases the remaining characters.
---

Makes the first character of a string capitalized and converts the remaining characters to lowercase.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "title" | capitalize }}
{{ "my GREAT title" | capitalize }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "title" | capitalize }}
{{ "my GREAT title" | capitalize }}
```
