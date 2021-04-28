---
title: reverse
description: Liquid filter that reverses an array, or a string converted to an array.
---

Reverses the order of the items in an array. `reverse` cannot reverse a string.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array | reverse | join: ", " }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array | reverse | join: ", " }}
```

Although `reverse` cannot be used directly on a string, you can split a string into an array, reverse the array, and rejoin it by chaining together filters.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Ground control to Major Tom." | split: "" | reverse | join: "" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | split: "" | reverse | join: "" }}
```
