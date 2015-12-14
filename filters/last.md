---
title: last
---

`last` returns the last element of an array without sorting the array.

```liquid
{% raw %}
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array.last }}
{% endraw %}
```

```text
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array.last }}
```

```liquid
{% raw %}
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.last }}
{% endraw %}
```

```text
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.last }}
```
