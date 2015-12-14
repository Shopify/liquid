---
title: lstrip
---

`lstrip` removes all whitespace (tabs, spaces, and newlines) from the left side of a string.

```liquid
{% raw %}
{{ "          So much room for activities!          " | lstrip }}
{% endraw %}
```

```text
{{ "          So much room for activities!          " | lstrip }}
```
