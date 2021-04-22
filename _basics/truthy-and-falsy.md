---
title: Truthy and falsy
description: An overview of boolean logic in the Liquid template language.
---

When a non-boolean [data type]({{ "/basics/types/" | prepend: site.baseurl }}) is used in a boolean context (such as a conditional tag), Liquid decides whether to evaluate it as `true` or `false`. Data types that return `true` by default are called **truthy**. Data types that return false by default are called **falsy**.

## Truthy

All values in Liquid are truthy except `nil` and `false`.

In the example below, the text "Tobi" is not a boolean, but it is truthy in a conditional:

```liquid
{%- raw -%}
{% assign name = "Tobi" %}

{% if name %}
  This text will always appear since "name" is defined.
{% endif %}
{% endraw %}
```

[Strings]({{ "/basics/types/#string" | prepend: site.baseurl }}), even when empty, are truthy. The example below will create empty HTML tags if `page.category` exists but is empty:

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% if page.category %}
  <h1>{{ page.category }}</h1>
{% endif %}
{% endraw %}
```

<p class="code-label">Output</p>
```html
  <h1></h1>
```

## Falsy

The only values that are falsy in Liquid are [`nil`]({{ "/basics/types/#nil" | prepend: site.baseurl }}) and [`false`]({{ "/basics/types/#boolean" | prepend: site.baseurl }}).

## Summary

The table below summarizes what is truthy or falsy in Liquid.

|               | truthy        | falsy         |
| ------------- |:-------------:|:-------------:|
| true          | •             |               |
| false         |               | •             |
| nil           |               | •             |
| string        | •             |               |
| empty string  | •             |               |
| 0             | •             |               |
| integer       | •             |               |
| float         | •             |               |
| array         | •             |               |
| empty array   | •             |               |
| page          | •             |               |
| EmptyDrop     | •             |               |
