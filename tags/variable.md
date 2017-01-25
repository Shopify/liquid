---
title: Variable
description: An overview of tags for creating variables in the Liquid template language.
---

Variable tags create new Liquid variables.

## assign

Creates a new variable.

<p class="code-label">Input</p>
```liquid
{% raw %}
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

Wrap a variable in quotations `"` to save it as a string.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign foo = "bar" %}
{{ foo }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
bar
```

## capture

Captures the string inside of the opening and closing tags and assigns it to a variable. Variables created through `{% raw %}{% capture %}{% endraw %}` are strings.

<p class="code-label">Input</p>
```liquid
{% raw %}
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
```text
{% assign favorite_food = 'pizza' %}
{% assign age = 35 %}

{% capture about_me %}
I am {{ age }} and my favorite food is {{ favorite_food }}.
{% endcapture %}

{{ about_me }}
```

<p class="code-label">Output</p>
```text
I am 35 and my favourite food is pizza.
```

## increment

Creates a new number variable, and increases its value by one every time it is called. The initial value is 0.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% increment my_counter %}
{% increment my_counter %}
{% increment my_counter %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
0
1
2
```

Variables created through the `increment` tag are independent from variables created through `assign` or `capture`.

In the example below, a variable named "var" is created through `assign`. The `increment` tag is then used several times on a variable with the same name. Note that the `increment` tag does not affect the value of "var" that was created through `assign`.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign var = 10 %}
{% increment var %}
{% increment var %}
{% increment var %}
{{ var }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
0
1
2
10
```

## decrement

Creates a new number variable, and decreases its value by one every time it is called. The initial value is -1.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% decrement variable %}
{% decrement variable %}
{% decrement variable %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
-1
-2
-3
```

Like [increment](#increment), variables declared inside `decrement` are independent from variables created through `assign` or `capture`.
