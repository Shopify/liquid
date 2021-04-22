---
title: uniq
description: Liquid filter that removes duplicate items from an array.
---

Removes any duplicate items in an array.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_array = "ants, bugs, bees, bugs, ants" | split: ", " %}

{{ my_array | uniq | join: ", " }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "ants, bugs, bees, bugs, ants" | split: ", " %}

{{ my_array | uniq | join: ", " }}
```
