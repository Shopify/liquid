---
title: truncatewords
---

Shortens a string down to the number of words passed as the argument. If the specified number of words is less than the number of words in the string, an ellipsis (...) is appended to the string.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "Ground control to Major Tom." | truncatewords: 3 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | truncatewords: 3 }}
```
