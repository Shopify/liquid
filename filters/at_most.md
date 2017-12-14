---
title: at_most
description: Liquid filter that limits a number to a maximum value
---

Limits a number to a maximum value.

<p class="code-label">Input</p>
{% raw %}
```liquid
{{ 4 | at_most: 5 }}
```
{% endraw %}

<p class="code-label">Output</p>
```
4
```

<p class="code-label">Input</p>
{% raw %}
```liquid
{{ 4 | at_most: 3 }}
```
{% endraw %}

<p class="code-label">Output</p>
```
3
```
