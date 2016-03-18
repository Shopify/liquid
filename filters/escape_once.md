---
title: escape_once
---

Escapes a string without changing existing escaped entities. It doesn't change strings that don't have anything to escape.

```liquid
{% raw %}
{{ "1 < 2 & 3" | escape_once }}
{% endraw %}
```

```text
{{ "1 < 2 & 3" | escape_once }}
```

```liquid
{% raw %}
{{ "1 &lt; 2 &amp; 3" | escape_once }}
{% endraw %}
```

```text
{{ "1 &lt; 2 &amp; 3" | escape_once }}
```
