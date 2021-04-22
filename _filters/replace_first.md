---
title: replace_first
description: Liquid filter that replaces the first occurrence of a given substring in a string.
---

Replaces only the first occurrence of the first argument in a string with the second argument.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
```
