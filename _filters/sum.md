---
title: sum
description: Liquid filter that sums all items in an array.
---

Sums all items in an array.

If a string is passed as an argument, it sums the property values.

In this example, assume the object `collection.products` contains a list of products, and each `product` object has a `quantity` property. Using `assign` with the `sum` filter creates a variable that contains the total quantity for all products in the collection.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign total_quantity = collection.products | sum: "quantity" %}

{{ total_quantity }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
6
```

The `sum` filter also works without any argument.

In this example, assume the object `article.ratings` is an array of integers. Using `assign` with the `sum` filter creates a variable that contains the total ratings for the article.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign total_rating = article.ratings | sum %}

{{ total_rating }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
6
```
