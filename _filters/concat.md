---
title: concat
description: Liquid filter that concatenates arrays.
version-badge: 4.0.0
---

Concatenates (joins together) multiple arrays. The resulting array contains all the items from the input arrays.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign fruits = "apples, oranges, peaches" | split: ", " %}
{% assign vegetables = "carrots, turnips, potatoes" | split: ", " %}

{% assign everything = fruits | concat: vegetables %}

{% for item in everything %}
- {{ item }}
{% endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
- apples
- oranges
- peaches
- carrots
- turnips
- potatoes
```

You can string together multiple `concat` filters to join more than two arrays.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign furniture = "chairs, tables, shelves" | split: ", " %}

{% assign everything = fruits | concat: vegetables | concat: furniture %}

{% for item in everything %}
- {{ item }}
{% endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
- apples
- oranges
- peaches
- carrots
- turnips
- potatoes
- chairs
- tables
- shelves
```
