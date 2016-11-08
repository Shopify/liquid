---
title: abs
description: Liquid filter that gets the absolute value of a number.
---

Returns the absolute value of a number.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ -17 | abs }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
17
```

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ 4 | abs }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
4
```

`abs` will also work on a string if the string only contains a number.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "-19.86" | abs }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
19.86
```
