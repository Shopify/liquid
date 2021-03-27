---
title: append
description: Liquid filter that appends a string to another string.
---

Adds the specified string to the end of another string. `append` can also accept a variable as its argument.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "/my/fancy/url" | append: ".html" }}
{% assign filename = "/index.html" %} {{ "website.com" | append: filename }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "/my/fancy/url" | append: ".html" }}
{% assign filename = "/index.html" -%} {{ "website.com" | append: filename }}
```
