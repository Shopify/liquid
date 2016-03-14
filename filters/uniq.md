---
title: uniq
---

Removes any duplicate elements in an array.

```liquid
{% raw %}
{% assign my_array = "ants, bugs, bees, bugs, ants" | split: ", " %}

{{ my_array | uniq | join: ", " }}
{% endraw %}
```

```text
{% assign my_array = "ants, bugs, bees, bugs, ants" | split: ", " %}

{{ my_array | uniq | join: ", " }}
```
