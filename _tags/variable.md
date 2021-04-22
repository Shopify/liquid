---
title: Variable
description: An overview of tags for creating variables in the Liquid template language.
---

Variable tags create new Liquid variables.

## assign

Creates a new named variable.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign my_variable = false %}
{% if my_variable != true %}
  This statement is valid.
{% endif %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
This statement is valid.
```

Wrap a value in quotations `"` to save it as a string variable.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign foo = "bar" %}
{{ foo }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign foo = "bar" %}
{{ foo }}
```

## capture

Captures the string inside of the opening and closing tags and assigns it to a variable. Variables created using `capture` are stored as strings.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% capture my_variable %}I am being captured.{% endcapture %}
{{ my_variable }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
I am being captured.
```

Using `capture`, you can create complex strings using other variables created with `assign`.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign favorite_food = "pizza" %}
{% assign age = 35 %}

{% capture about_me %}
I am {{ age }} and my favorite food is {{ favorite_food }}.
{% endcapture %}

{{ about_me }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
I am 35 and my favourite food is pizza.
```

## increment

Creates and outputs a new number variable with initial value `0`. On subsequent calls, it increases its value by one and outputs the new value.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% increment my_counter %}
{% increment my_counter %}
{% increment my_counter %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% increment my_counter %}
{% increment my_counter %}
{% increment my_counter %}
```

Variables created using `increment` are independent from variables created using `assign` or `capture`.

In the example below, a variable named "var" is created using `assign`. The `increment` tag is then used several times on a variable with the same name. Note that the `increment` tag does not affect the value of "var" that was created using `assign`.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign var = 10 %}
{% increment var %}
{% increment var %}
{% increment var %}
{{ var }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign var = 10 %}
{% increment var %}
{% increment var %}
{% increment var %}
{{ var }}
```

## decrement

Creates and outputs a new number variable with initial value `-1`. On subsequent calls, it decreases its value by one and outputs the new value.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% decrement variable %}
{% decrement variable %}
{% decrement variable %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% decrement variable %}
{% decrement variable %}
{% decrement variable %}
```

Like [increment](#increment), variables declared using `decrement` are independent from variables created using `assign` or `capture`.
