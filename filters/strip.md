---
title: strip
---

`strip` removes all whitespace (tabs, spaces, and newlines) from both the left and right sides of a string. It does not affect spaces between words.

```liquid
{% raw %}
{{ "          So much room for activities!          " | strip }}
{% endraw %}
```

```text
{{ "          So much room for activities!          " | strip }}
```
