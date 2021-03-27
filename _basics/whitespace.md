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

By including hyphens in your `assign` tag, you can strip the generated whitespace from the rendered template:

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{%- assign my_variable = "tomato" -%}
{{ my_variable }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
tomato
```

## Avoiding whitespace using hyphens

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

## Avoiding whitespace without hyphens {%- include version-badge.html version="5.0.0" %}

If you use the [`liquid`]({{ '/tags/template#liquid500' | prepend: site.baseurl }}) tag with the `echo` keyword, you can avoid whitespace without adding hyphens throughout the Liquid code:

```liquid
{%- raw -%}
{% liquid
assign username = "John G. Chalmers-Smith"
if username and username.size > 10
  echo "Wow, " | append: username | append: ", you have a long name!"
else
  echo "Hello there!"
endif
%}
{% endraw %}
```

## Note about the Liquid docs

In the rest of the documentation, some example output text may exclude whitespace even if the corresponding input Liquid code doesn't have any hyphens. The example output is for illustrating the effects of a given tag or filter only. It shouldn't be treated as a precise output of the given input code.
