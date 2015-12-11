---
title: default
---

`default` offers a means of having a fallback in case your value doesn't exist. `default` will use its substitute if the left side is `nil`, `false`, or empty.

In this example, `product_price` is not defined, so the default value is used.

```liquid
{% raw %}
{{ product_price | default: 2.99 }}
{% endraw %}
```

```text
2.99
```

In this example, `product_price` is defined, so the default value is not used.

```liquid
{% raw %}
{% assign product_price = 4.99 %}
{{ product_price | default:2.99 }}
{% endraw %}
```

```text
4.99
```

In this example, `product_price` is empty, so the default value is used.

```liquid
{% raw %}
{% assign product_price = "" %}
{{ product_price | default: 2.99 }}
{% endraw %}
```

```text
2.99
```

