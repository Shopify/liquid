---
title: lstrip
description: Liquid filter that removes whitespace from the left side of a string.
---

Removes all whitespaces (tabs, spaces, and newlines) from the beginning of a string. The filter does not affect spaces between words.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "          So much room for activities!          " | lstrip }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "          So much room for activities!          " | lstrip }}
```
