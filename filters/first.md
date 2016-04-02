---
title: first
---

Returns the first item of an array.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array.first }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array.first }}
```

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.first }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.first }}
```
