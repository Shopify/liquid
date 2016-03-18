---
title: join
---

Combines the items in an array into a single string using the argument as a separator.

```liquid
{% raw %}
{% assign beatles = "John, Paul, George, Ringo" | split: ", " %}

{{ beatles | join: " and " }}
{% endraw %}
```

```text
{% assign beatles = "John, Paul, George, Ringo" | split: ", " %}

{{ beatles | join: " and " }}
```
