---
title: divided_by
---

Divides a number by the specified number.

The result is rounded down to the nearest integer (that is, the [floor]({{ "/filters/floor" | prepend: site.baseurl }})).

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ 4 | divided_by: 2 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 4 | divided_by: 2 }}
```

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ 16 | divided_by: 4 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 16 | divided_by: 4 }}
```

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ 5 | divided_by: 3 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 5 | divided_by: 3 }}
```
