---
title: split
description: Liquid filter that splits a string into an array using separators.
---

Divides a string into an array using the argument as a separator. `split` is commonly used to convert comma-separated items from a string to an array.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign beatles = "John, Paul, George, Ringo" | split: ", " %}

{% for member in beatles %}
  {{ member }}
{% endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign beatles = "John, Paul, George, Ringo" | split: ", " %}

{% for member in beatles %}
  {{ member }}
{% endfor %}
```
