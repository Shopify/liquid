---
title: Control flow
description: An overview of control flow and conditional tags in the Liquid template language.
---

Control flow tags can change the information Liquid shows using programming logic.

## if

Executes a block of code only if a certain condition is `true`.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% if product.title == 'Awesome Shoes' %}
  These shoes are awesome!
{% endif %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
These shoes are awesome!
```

## unless

The opposite of `if` – executes a block of code only if a certain condition is **not** met.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% unless product.title == 'Awesome Shoes' %}
  These shoes are not awesome.
{% endunless %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
These shoes are not awesome.
```

This would be the equivalent of doing the following:

```liquid
{% raw %}
{% if product.title != 'Awesome Shoes' %}
  These shoes are not awesome.
{% endif %}
{% endraw %}
```

## elsif / else

Adds more conditions within an `if` or `unless` block.

<p class="code-label">Input</p>
```liquid
{% raw %}
<!-- If customer.name = 'anonymous' -->
{% if customer.name == 'kevin' %}
  Hey Kevin!
{% elsif customer.name == 'anonymous' %}
  Hey Anonymous!
{% else %}
  Hi Stranger!
{% endif %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
Hey Anonymous!
```

## case/when

Creates a switch statement to compare a variable with different values. `case` initializes the switch statement, and `when` compares its values.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% assign handle = 'cake' %}
{% case handle %}
  {% when 'cake' %}
     This is a cake
  {% when 'cookie' %}
     This is a cookie
  {% else %}
     This is not a cake nor a cookie
{% endcase %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
This is a cake
```
