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

In the example below, the string "Tobi" is not a boolean, but it is truthy in a conditional:

```liquid
{% raw %}
{% assign tobi = "Tobi" %}

{% if tobi %}
  This condition will always be true.
{% endif %}
{% endraw %}
```

[Strings]({{ "/basics/types/#string" | prepend: site.baseurl }}), even when empty, are truthy. The example below will result in empty HTML tags if `settings.fp_heading` is empty:

<p class="code-label">Input</p>
```liquid
{% raw %}
{% if settings.fp_heading %}
  <h1>{{ settings.fp_heading }}</h1>
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
