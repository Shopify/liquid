---
title: append
---

`append` concatenates two strings and returns the concatenated value.

```liquid
{% raw %}
{{ "/my/fancy/url" | append:".html" }}
{% endraw %}
```

```text
/my/fancy/url.html
```

`append` can also be used with variables:

```liquid
{% raw %}
{% assign filename = "/index.html" %}
{{ product.url | append: filename }}
{% endraw %}
```

```liquid
{% raw %}
{{ product.url }}/index.html
{% endraw %}
```
