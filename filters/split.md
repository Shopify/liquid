---
title: split
---

Divides an input string into an array using the argument as a separator. `split` is commonly used to convert comma-separated items from a string to an array.

```liquid
{% raw %}
{% assign beatles = "John, Paul, George, Ringo" | split: ", " %}

{% for member in beatles %}
  {{ member }}
{% endfor %}
{% endraw %}
```

```text
{% assign beatles = "John, Paul, George, Ringo" | split: ", " %}

{% for member in beatles %}
  {{ member }}
{% endfor %}
```
