---
title: Operators
description: Using operators to perform calculations in the Liquid template language.
---

Liquid includes many logical and comparison operators.

## Basic operators

<table>
  <tbody>
    <tr>
      <td><code>==</code></td>
      <td>equals</td>
    </tr>
    <tr>
      <td><code>!=</code></td>
      <td>does not equal</td>
    </tr>
    <tr>
      <td><code>&gt;</code></td>
      <td>greater than</td>
    </tr>
    <tr>
      <td><code>&lt;</code></td>
      <td>less than</td>
    </tr>
    <tr>
      <td><code>&gt;=</code></td>
      <td>greater than or equal to</td>
    </tr>
    <tr>
      <td><code>&lt;=</code></td>
      <td>less than or equal to</td>
    </tr>
    <tr>
      <td><code>or</code></td>
      <td>logical or</td>
    </tr>
    <tr>
      <td><code>and</code></td>
      <td>logical and</td>
    </tr>
  </tbody>
</table>

For example:

```liquid
{% raw %}
{% if product.title == "Awesome Shoes" %}
  These shoes are awesome!
{% endif %}
{% endraw %}
```

You can use multiple operators in a tag:

```liquid
{% raw %}
{% if product.type == "Shirt" or product.type == "Shoes" %}
  This is a shirt or a pair of shoes.
{% endif %}
{% endraw %}
```

## contains

`contains` checks for the presence of a substring inside a string.

```liquid
{% raw %}
{% if product.title contains 'Pack' %}
  This product's title contains the word Pack.
{% endif %}
{% endraw %}
```

`contains` can also check for the presence of a string in an array of strings.

```liquid
{% raw %}
{% if product.tags contains 'Hello' %}
  This product has been tagged with 'Hello'.
{% endif %}
{% endraw %}
```

`contains` can only search strings. You cannot use it to check for an object in an array of objects.
