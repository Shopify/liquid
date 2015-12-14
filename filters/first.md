---
title: first
---

`first` returns the first element of an array without sorting the array.

```liquid
{% raw %}
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array.first }}
{% endraw %}
```

```text
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array.first }}
```

```liquid
{% raw %}
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.first }}
{% endraw %}
```

```text
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.first }}
```
