---
title: append
---

Concatenates two strings and returns the concatenated value.

```liquid
{% raw %}
{{ "/my/fancy/url" | append: ".html" }}
{% endraw %}
```

```text
{{ "/my/fancy/url" | append: ".html" }}
```

`append` can also be used with variables:

```liquid
{% raw %}
{% assign filename = "/index.html" %}
{{ "website.com" | append: filename }}
{% endraw %}
```

```text
{% assign filename = "/index.html" %}
{{ "website.com" | append: filename }}
```
