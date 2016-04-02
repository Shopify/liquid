---
title: strip_html
---

Removes any HTML tags from a string.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "Have <em>you</em> read <strong>Ulysses</strong>?" | strip_html }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Have <em>you</em> read <strong>Ulysses</strong>?" | strip_html }}
```
