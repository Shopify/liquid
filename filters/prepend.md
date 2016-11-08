---
title: prepend
description: Liquid filter that prepends a string to the beginning of another string.
---

Adds the specified string to the beginning of another string.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "apples, oranges, and bananas" | prepend: "Some fruit: " }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "apples, oranges, and bananas" | prepend: "Some fruit: " }}
```

You can also `prepend` variables:

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign url = "liquidmarkup.com" %}

{{ "/index.html" | prepend: url }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign url = "liquidmarkup.com" %}

{{ "/index.html" | prepend: url }}
```
