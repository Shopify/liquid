---
title: size
description: Liquid filter that returns the number of characters in a string or the number of items in an array.
---

Returns the number of characters in a string or the number of items in an array.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Ground control to Major Tom." | size }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | size }}
```

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array.size }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array.size }}
```

You can use `size` with dot notation when you need to use the filter inside a tag:

```liquid
{%- raw -%}
{% if site.pages.size > 10 %}
  This is a big website!
{% endif %}
{% endraw %}
```
