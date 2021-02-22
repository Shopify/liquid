---
title: Truthy and falsy
description: An overview of boolean logic in the Liquid template language.
---

In programming, anything that returns `true` in a conditional is called **truthy**. Anything that returns `false` in a conditional is called **falsy**. All object types can be described as either truthy or falsy.

- [Truthy](#truthy)
- [Falsy](#falsy)
- [Summary](#summary)

## Truthy

All values in Liquid are truthy except `nil` and `false`.

In the example below, the text "Tobi" is not a boolean, but it is truthy in a conditional:

```liquid
{% raw %}
{% assign name = "Tobi" %}

{% if name %}
  This text will always appear if "name" is defined.
{% endif %}
{% endraw %}
```

[Strings]({{ "/basics/types/#string" | prepend: site.baseurl }}), even when empty, are truthy. The example below will create empty HTML tags if `page.category` exists but is empty:

<p class="code-label">Input</p>
```liquid
{% raw %}
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

The falsy values in Liquid are [`nil`]({{ "/basics/types/#nil" | prepend: site.baseurl }}) and [`false`]({{ "/basics/types/#boolean" | prepend: site.baseurl }}).

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
