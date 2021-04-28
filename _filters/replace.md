---
title: replace
description: Liquid filter that replaces all occurences of a given substring in a string.
---

Replaces every occurrence of the first argument in a string with the second argument.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Take my protein pills and put my helmet on" | replace: "my", "your" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Take my protein pills and put my helmet on" | replace: "my", "your" }}
```
