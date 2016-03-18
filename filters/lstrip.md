---
title: lstrip
---

Removes all whitespaces (tabs, spaces, and newlines) from the beginning of a string. The filter does not affect spaces between words.

```liquid
{% raw %}
{{ "          So much room for activities!          " | lstrip }}
{% endraw %}
```

```text
{{ "          So much room for activities!          " | lstrip }}
```
