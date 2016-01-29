---
title: map
---

Creates an array of values by extracting the values of a named property from another object.

In this example, assume the object `site.pages` contains all the metadata for a website. Using `assign` with the `map` filter creates a variable that contains only the values of the `category` properties of everything in the `site.pages` object.

```liquid
{% raw %}
{% assign all_categories = site.pages | map: "category" %}

{% for item in all_categories %}
{{ item }}
{% endfor %}
{% endraw %}
```

```text
business
celebrities
lifestyle
sports
technology
```
