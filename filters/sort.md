---
title: sort
---

Sorts items in an array by a property of an item in the array. The order of the sorted array is case-sensitive.

```liquid
{% raw %}
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " %}

{{ my_array | sort | join: ", " }}
{% endraw %}
```

```text
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " %}

{{ my_array | sort | join: ", " }}
```
