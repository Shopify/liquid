---
title: escape_once
description: Liquid filter that escapes URL-unsafe characters in a string once.
---

Escapes a string without changing existing escaped entities. It doesn't change strings that don't have anything to escape.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "1 < 2 & 3" | escape_once }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "1 < 2 & 3" | escape_once }}
```

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "1 &lt; 2 &amp; 3" | escape_once }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "1 &lt; 2 &amp; 3" | escape_once }}
```
