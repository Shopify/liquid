---
title: sort
description: Liquid filter that sorts an array in case-sensitive order.
---

Sorts items in an array in case-sensitive order.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " %}

{{ my_array | sort | join: ", " }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " %}

{{ my_array | sort | join: ", " }}
```

An optional argument specifies which property of the array's items to use for sorting.

```liquid
{%- raw -%}
{% assign products_by_price = collection.products | sort: "price" %}
{% for product in products_by_price %}
  <h4>{{ product.title }}</h4>
{% endfor %}
{% endraw %}
```
