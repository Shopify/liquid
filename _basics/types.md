---
title: Types
description: An overview of data types in the Liquid template language.
---

Liquid objects can be one of six types:

- [String](#string)
- [Number](#number)
- [Boolean](#boolean)
- [Nil](#nil)
- [Array](#array)
- [EmptyDrop](#emptydrop)

You can initialize Liquid variables using [`assign`]({{ "/tags/variable/#assign" | prepend: site.baseurl }}) or [`capture`]({{ "/tags/variable/#capture" | prepend: site.baseurl }}) tags.

## String

Strings are sequences of characters wrapped in single or double quotes:

```liquid
{%- raw -%}
{% assign my_string = "Hello World!" %}
{% endraw %}
```

Liquid does not convert escape sequences into special characters.

## Number

Numbers include floats and integers:

```liquid
{%- raw -%}
{% assign my_int = 25 %}
{% assign my_float = -39.756 %}
{% endraw %}
```

## Boolean

Booleans are either `true` or `false`. No quotations are necessary when declaring a boolean:

```liquid
{%- raw -%}
{% assign foo = true %}
{% assign bar = false %}
{% endraw %}
```

## Nil

Nil is a special empty value that is returned when Liquid code has no results. It is **not** a string with the characters "nil".

Nil is [treated as false]({{ "/basics/truthy-and-falsy/#falsy" | prepend: site.baseurl }}) in the conditions of `if` blocks and other Liquid tags that check the truthfulness of a statement.

In the following example, if the user does not exist (that is, `user` returns `nil`), Liquid will not print the greeting:

```liquid
{%- raw -%}
{% if user %}
  Hello {{ user.name }}!
{% endif %}
{% endraw %}
```

Tags or outputs that return `nil` will not print anything to the page.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
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

To access all the items in an array, you can loop through each item in the array using an [iteration tag]({{ "/tags/iteration/" | prepend: site.baseurl }}).

<p class="code-label">Input</p>
```liquid
{%- raw -%}
<!-- if site.users = "Tobi", "Laura", "Tetsuro", "Adam" -->
{% for user in site.users %}
  {{ user }}
{% endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
  Tobi Laura Tetsuro Adam
```

### Accessing specific items in arrays

You can use square bracket `[` `]` notation to access a specific item in an array. Array indexing starts at zero. A negative index will count from the end of the array.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
<!-- if site.users = "Tobi", "Laura", "Tetsuro", "Adam" -->
{{ site.users[0] }}
{{ site.users[1] }}
{{ site.users[-1] }}
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

You can, however, use the [`split`]({{ "/filters/split/" | prepend: site.baseurl }}) filter to break a string into an array of substrings.

## EmptyDrop

An EmptyDrop object is returned if you try to access a deleted object. In the example below, `page_1`, `page_2` and `page_3` are all EmptyDrop objects:

```liquid
{%- raw -%}
{% assign variable = "hello" %}
{% assign page_1 = pages[variable] %}
{% assign page_2 = pages["does-not-exist"] %}
{% assign page_3 = pages.this-handle-does-not-exist %}
{% endraw %}
```

### Checking for emptiness

You can check to see if an object exists or not before you access any of its attributes.

```liquid
{%- raw -%}
{% unless pages == empty %}
  <h1>{{ pages.frontpage.title }}</h1>
  <div>{{ pages.frontpage.content }}</div>
{% endunless %}
{% endraw %}
```

Both empty strings and empty arrays will return `true` if checked for equivalence with `empty`.
