---
title: Control flow
---

Control flow tags can change the information Liquid shows using programming logic.

## case/when

Creates a switch statement to compare a variable with different values. `case` initializes the switch statement, and `when` compares its values.

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

```text
This is a cake
```

## if

Executes a block of code only if a certain condition is `true`.

```liquid
{% raw %}
{% if product.title == 'Awesome Shoes' %}
  These shoes are awesome!
{% endif %}
{% endraw %}
```

```text
These shoes are awesome!
```

## unless

The opposite of `if` – executes a block of code only if a certain condition is **not** met.

```liquid
{% raw %}
{% unless product.title == 'Awesome Shoes' %}
  These shoes are not awesome.
{% endunless %}
{% endraw %}
```

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

```text
Hey Anonymous!
```
