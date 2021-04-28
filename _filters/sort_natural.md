---
title: sort_natural
description: Liquid filter that sorts an array in case-insensitive order.
version-badge: 4.0.0
---

Sorts items in an array in case-insensitive order.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " %}

{{ my_array | sort_natural | join: ", " }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " %}

{{ my_array | sort_natural | join: ", " }}
```

An optional argument specifies which property of the array's items to use for sorting.

```liquid
{%- raw -%}
{% assign products_by_company = collection.products | sort_natural: "company" %}
{% for product in products_by_company %}
  <h4>{{ product.title }}</h4>
{% endfor %}
{% endraw %}
```
