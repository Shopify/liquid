---
title: Operators
description: Using operators to perform calculations in the Liquid template language.
---

Liquid includes many logical and comparison operators. You can use operators to create logic with [control flow]({{ "/tags/control-flow/" | prepend: site.baseurl }}) tags.

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
{%- raw -%}
{% if product.title == "Awesome Shoes" %}
  These shoes are awesome!
{% endif %}
{% endraw %}
```

You can do multiple comparisons in a tag using the `and` and `or` operators:

```liquid
{%- raw -%}
{% if product.type == "Shirt" or product.type == "Shoes" %}
  This is a shirt or a pair of shoes.
{% endif %}
{% endraw %}
```

## contains

`contains` checks for the presence of a substring inside a string.

```liquid
{%- raw -%}
{% if product.title contains "Pack" %}
  This product's title contains the word Pack.
{% endif %}
{% endraw %}
```

`contains` can also check for the presence of a string in an array of strings.

```liquid
{%- raw -%}
{% if product.tags contains "Hello" %}
  This product has been tagged with "Hello".
{% endif %}
{% endraw %}
```

`contains` can only search strings. You cannot use it to check for an object in an array of objects.

## Order of operations

In tags with more than one `and` or `or` operator, operators are checked in order *from right to left*. You cannot change the order of operations using parentheses — parentheses are invalid characters in Liquid and will prevent your tags from working.

```liquid
{%- raw -%}
{% if true or false and false %}
  This evaluates to true, since the `and` condition is checked first.
{% endif %}
{% endraw %}
```

```liquid
{%- raw -%}
{% if true and false and false or true %}
  This evaluates to false, since the tags are checked like this:

  true and (false and (false or true))
  true and (false and true)
  true and false
  false
{% endif %}
{% endraw %}
```
