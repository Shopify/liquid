---
title: modulo
description: Liquid filter that returns the remainder from a division operation.
---

Returns the remainder of a division operation.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ 3 | modulo: 2 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 3 | modulo: 2 }}
```

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ 24 | modulo: 7 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 24 | modulo: 7 }}
```

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ 183.357 | modulo: 12 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ 183.357 | modulo: 12 }}
```
