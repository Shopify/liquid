---
title: join
---

`join` combines the elements of an array into a single string using the string you provide as a separator.

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
