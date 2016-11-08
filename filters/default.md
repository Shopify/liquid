---
title: default
description: Liquid filter that specifies a fallback in case a value doesn't exist.
---

Allows you to specify a fallback in case a value doesn't exist. `default` will show its value if the left side is `nil`, `false`, or empty.

In this example, `product_price` is not defined, so the default value is used.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ product_price | default: 2.99 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
2.99
```

In this example, `product_price` is defined, so the default value is not used.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign product_price = 4.99 %}
{{ product_price | default: 2.99 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
4.99
```

In this example, `product_price` is empty, so the default value is used.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign product_price = "" %}
{{ product_price | default: 2.99 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
2.99
```
