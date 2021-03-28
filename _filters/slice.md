---
title: slice
category: string
description: Liquid filter that returns a substring or item from a given position in a string or array.
---

Returns a substring of one character or series of array items beginning at the index specified by the first argument. An optional second argument specifies the length of the substring or number of array items to be returned.

String or array indices are numbered starting from `0`. If the first argument is a negative number, the indices are counted from the end of the string.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Liquid" | slice: 0 }}
{{ "Liquid" | slice: 2 }}
{{ "Liquid" | slice: 2, 5 }}
{{ "Liquid" | slice: -3, 2 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Liquid" | slice: 0 }}
{{ "Liquid" | slice: 2 }}
{{ "Liquid" | slice: 2, 5 }}
{{ "Liquid" | slice: -3, 2 }}
```

When the input value is an array, the matching items are concatenated and returned:

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
{{ beatles | slice: 1, 2 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{% assign beatles = "John, Paul, George, Ringo" | split: ", " -%}
{{ beatles | slice: 1, 2 }}
```
