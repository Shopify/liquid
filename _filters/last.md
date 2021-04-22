---
title: last
description: Liquid filter that returns the last item of an array.
---

Returns the last item of an array.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Ground control to Major Tom." | split: " " | last }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | split: " " | last }}
```

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.last }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "zebra, octopus, giraffe, tiger" | split: ", " %}

{{ my_array.last }}
```

You can use `last` with dot notation when you need to use the filter inside a tag:

```liquid
{%- raw -%}
{% if my_array.last == "tiger" %}
  There goes a tiger!
{% endif %}
{% endraw %}
```
