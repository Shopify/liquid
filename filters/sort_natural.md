---
title: sort_natural
description: Liquid filter that sorts an array in case-insensitive order.
---

Sorts items in an array by a property of an item in the array.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " %}

{{ my_array | sort_natural | join: ", " }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
giraffe, octopus, Sally Snake, zebra
```
