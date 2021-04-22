---
title: where
description: Liquid filter that selects from arrays.
version-badge: 4.0.2
---

Creates an array including only the objects with a given property value, or any [truthy]({{ "/basics/truthy-and-falsy/#truthy" | prepend: site.baseurl }}) value by default.

In this example, assume you have a list of products and you want to show your kitchen products separately. Using `where`, you can create an array containing only the products that have a `"type"` of `"kitchen"`.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
All products:
{% for product in products %}
- {{ product.title }}
{% endfor %}

{% assign kitchen_products = products | where: "type", "kitchen" %}

Kitchen products:
{% for product in kitchen_products %}
- {{ product.title }}
{% endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
All products:
- Vacuum
- Spatula
- Television
- Garlic press

Kitchen products:
- Spatula
- Garlic press
```

Say instead you have a list of products and you only want to show those that are available to buy. You can `where` with a property name but no target value to include all products with a [truthy]({{ "/basics/truthy-and-falsy/#truthy" | prepend: site.baseurl }}) `"available"` value.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
All products:
{% for product in products %}
- {{ product.title }}
{% endfor %}

{% assign available_products = products | where: "available" %}

Available products:
{% for product in available_products %}
- {{ product.title }}
{% endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
All products:
- Coffee mug
- Limited edition sneakers
- Boring sneakers

Available products:
- Coffee mug
- Boring sneakers
```

The `where` filter can also be used to find a single object in an array when combined with the `first` filter. For example, say you want to show off the shirt in your new fall collection.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign new_shirt = products | where: "type", "shirt" | first %}

Featured product: {{ new_shirt.title }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
Featured product: Hawaiian print sweater vest
```
