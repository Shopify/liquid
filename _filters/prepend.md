---
title: prepend
description: Liquid filter that prepends a string to the beginning of another string.
---

Adds the specified string to the beginning of another string.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "apples, oranges, and bananas" | prepend: "Some fruit: " }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "apples, oranges, and bananas" | prepend: "Some fruit: " }}
```

`prepend` can also accept a variable as its argument.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign url = "example.com" %}
{{ "/index.html" | prepend: url }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign url = "example.com" %}
{{ "/index.html" | prepend: url }}
```
