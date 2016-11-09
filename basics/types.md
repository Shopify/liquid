---
title: Types
description: An overview of data types in the Liquid template language.
---

Liquid objects can have one of six types:

- [String](#string)
- [Number](#number)
- [Boolean](#boolean)
- [Nil](#nil)
- [Array](#array)

You can initialize Liquid variables with the [assign]({{ "/tags/variable/#assign" | prepend: site.baseurl }}) or [capture]({{ "/tags/variable/#capture" | prepend: site.baseurl }}) tags.

## String

Declare a string by wrapping a variable's value in single or double quotes:

```liquid
{% raw %}
{% assign my_string = "Hello World!" %}
{% endraw %}
```

## Number

Numbers include floats and integers:

```liquid
{% raw %}
{% assign my_int = 25 %}
{% assign my_float = 39.756 %}
{% endraw %}
```

## Boolean

Booleans are either `true` or `false`. No quotations are necessary when declaring a boolean:

```liquid
{% raw %}
{% assign foo = true %}
{% assign bar = false %}
{% endraw %}
```

## Nil

Nil is a special empty value that is returned when Liquid code has no results. It is **not** a string with the characters "nil".

Nil is [treated as false]({{ "/basics/truthy-and-falsy" | prepend: site.baseurl }}) in the conditions of `if` blocks and other Liquid tags that check the truthfulness of a statement.

In the following example, if the user does not exist (that is, `user` returns `nil`), Liquid will not print the greeting:

```liquid
{% raw %}
{% if user %}
  Hello {{ user.name }}!
{% endif %}
{% endraw %}
```

Tags or outputs that return `nil` will not print anything to the page.

<p class="code-label">Input</p>
```liquid
{% raw %}
The current user is {{ user.name }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
The current user is
```

## Array

Arrays hold lists of variables of any type.

### Accessing items in arrays

To access all the items in an array, you can loop through each item in the array using an [iteration tag]({{ "/tags/iteration" | prepend: site.baseurl }}).

<p class="code-label">Input</p>
```liquid
{% raw %}
<!-- if site.users = "Tobi", "Laura", "Tetsuro", "Adam" -->
{% for user in site.users %}
  {{ user }}
{% endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% raw %}
Tobi Laura Tetsuro Adam
{% endraw %}
```

### Accessing specific items in arrays

You can use square bracket `[` `]` notation to access a specific item in an array. Array indexing starts at zero.

<p class="code-label">Input</p>
```liquid
{% raw %}
<!-- if site.users = "Tobi", "Laura", "Tetsuro", "Adam" -->
{{ site.users[0] }}
{{ site.users[1] }}
{{ site.users[3] }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
Tobi
Laura
Adam
```

### Initializing arrays

You cannot initialize arrays using only Liquid.

You can, however, use the [split]({{ "/filters/split" | prepend: site.baseurl }}) filter to break a string into an array of substrings.
