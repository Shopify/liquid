---
title: Whitespace control
description: An overview of controlling whitespace between code in the Liquid template language.
---

In Liquid, you can include a hyphen in your tag syntax `{% raw %}{{-{% endraw %}`, `{% raw %}-}}{% endraw %}`, `{% raw %}{%-{% endraw %}`, and `{% raw %}-%}{% endraw %}` to strip whitespace from the left or right side of a rendered tag.

Normally, even if it doesn't print text, any line of Liquid in your template will still print a blank line in your rendered HTML:

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_variable = "tomato" %}
{{ my_variable }}
{% endraw %}
```

Notice the blank line before "tomato" in the rendered template:

<p class="code-label">Output</p>
```text
{% assign my_variable = "tomato" %}
{{ my_variable }}
```

By including a hyphen in your `assign` closing delimiter, you can strip the whitespace following it from the rendered template:

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_variable = "tomato" -%}
{{ my_variable }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign my_variable = "tomato" -%}
{{ my_variable }}
```

If you don't want any of your tags to print whitespace, as a general rule you can add hyphens to both sides of all your tags (`{% raw %}{%-{% endraw %}` and `{% raw %}-%}{% endraw %}`):

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign username = "John G. Chalmers-Smith" %}
{% if username and username.size > 10 %}
  Wow, {{ username }} , you have a long name!
{% else %}
  Hello there!
{% endif %}
{% endraw %}
```

<p class="code-label">Output without whitespace control</p>
```text
{% assign username = "John G. Chalmers-Smith" %}
{% if username and username.size > 10 %}
  Wow, {{ username }} , you have a long name!
{% else %}
  Hello there!
{% endif %}
```

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign username = "John G. Chalmers-Smith" -%}
{%- if username and username.size > 10 -%}
  Wow, {{ username -}} , you have a long name!
{%- else -%}
  Hello there!
{%- endif %}
{% endraw %}
```

<p class="code-label">Output with whitespace control</p>
```text
{% assign username = "John G. Chalmers-Smith" -%}
{%- if username and username.size > 10 -%}
  Wow, {{ username -}} , you have a long name!
{%- else -%}
  Hello there!
{%- endif %}
```
