---
title: sort
description: Liquid filter that sorts an array in case-sensitive order.
---

Sorts items in an array by a property of an item in the array. The order of the sorted array is case-sensitive.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " %}

{{ my_array | sort | join: ", " }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " %}

{{ my_array | sort | join: ", " }}
```
