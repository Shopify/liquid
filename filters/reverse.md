---
title: reverse
---

Reverses the order of the items in an array. `reverse` cannot reverse a string.

```liquid
{% raw %}
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array | reverse | join: ", " }}
{% endraw %}
```

```text
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array | reverse | join: ", " }}
```

`reverse` cannot be used directly on a string, but you can split a string into an array, reverse the array, and rejoin it by chaining together filters:

```liquid
{% raw %}
{{ "Ground control to Major Tom." | split: "" | reverse | join: "" }}
{% endraw %}
```

```text
{{ "Ground control to Major Tom." | split: "" | reverse | join: "" }}
```
