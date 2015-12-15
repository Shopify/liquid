---
title: uniq
---

Removes any duplicate elements in an array.

```liquid
{% raw %}
{% assign my_array = "apples, oranges, bananas, oranges, apples" | split: ", " %}

{{ my_array | uniq | join: ", " }}
{% endraw %}
```

```text
{% assign my_array = "apples, oranges, bananas, oranges, apples" | split: ", " %}

{{ my_array | uniq | join: ", " }}
```
