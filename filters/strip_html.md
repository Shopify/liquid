---
title: strip_html
---

Removes any HTML tags from a string.

```liquid
{% raw %}
{{ "Have <em>you</em> read <strong>Ulysses</strong>?" | strip_html }}
{% endraw %}
```

```text
{{ "Have <em>you</em> read <strong>Ulysses</strong>?" | strip_html }}
```
