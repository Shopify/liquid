---
title: escape_once
category: string
description: Liquid filter that escapes URL-unsafe characters in a string once.
---

Escapes a string without changing existing escaped entities. Notice the difference between `escape` and `escape_once` in their output:

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "1 < 2 & 3" | escape_once }}
{{ "1 &lt; 2 &amp; 3" | escape }}
{{ "1 &lt; 2 &amp; 3" | escape_once }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "1 < 2 & 3" | escape_once }}
{{ "1 &lt; 2 &amp; 3" | escape }}
{{ "1 &lt; 2 &amp; 3" | escape_once }}
```
