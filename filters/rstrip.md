---
title: rstrip
---

Removes all whitespace (tabs, spaces, and newlines) from the right side of a string.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "          So much room for activities!          " | rstrip }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "          So much room for activities!          " | rstrip }}
```
