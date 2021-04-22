---
title: truncate
description: Liquid filter that truncates a string to a given number of characters.
---

Shortens a string down to the number of characters passed as an argument. If the specified number of characters is less than the length of the string, an ellipsis (...) is appended to the string and is included in the character count.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Ground control to Major Tom." | truncate: 20 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | truncate: 20 }}
```

### Custom ellipsis

`truncate` takes an optional second argument that specifies the sequence of characters to be appended to the truncated string. By default this is an ellipsis (...), but you can specify a different sequence.

The length of the second argument counts against the number of characters specified by the first argument. For example, if you want to truncate a string to exactly 10 characters, and use a 3-character ellipsis, use **13** for the first argument of `truncate`, since the ellipsis counts as 3 characters.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Ground control to Major Tom." | truncate: 25, ", and so on" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | truncate: 25, ", and so on" }}
```

### No ellipsis

You can truncate to the exact number of characters specified by the first argument and avoid showing trailing characters by passing a blank string as the second argument.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "Ground control to Major Tom." | truncate: 20, "" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | truncate: 20, "" }}
```
