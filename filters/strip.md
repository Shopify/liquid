---
title: strip
---

Removes all whitespace (tabs, spaces, and newlines) from both the left and right side of a string. It does not affect spaces between words.

```liquid
{% raw %}
{{ "          So much room for activities!          " | strip }}
{% endraw %}
```

```text
{{ "          So much room for activities!          " | strip }}
```
