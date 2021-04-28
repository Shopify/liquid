---
title: first
description: Liquid filter that returns the first item of an array.
---

Returns the first item of an array.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Ground control to Major Tom." | split: " " | first }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | split: " " | first }}
```

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.first }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.first }}
```

You can use `first` with dot notation when you need to use the filter inside a tag:

```liquid
{%- raw -%}
{% if my_array.first == "zebra" %}
  Here comes a zebra!
{% endif %}
{% endraw %}
```
