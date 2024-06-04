---
title: remove_last
description: Liquid filter that removes the last occurence of a given substring from a string.
version-badge: 5.2.0
---

Removes only the last occurrence of the specified substring from a string.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "I strained to see the train through the rain" | remove_last: "rain" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
I strained to see the train through the
```
