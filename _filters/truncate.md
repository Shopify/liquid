---
title: truncate
description: Liquid filter that truncates a string to a given number of characters.
---

`truncate` shortens a string  down to the number of characters passed as a parameter. If the number of characters specified is less than the length of the string, an ellipsis (...) is appended to the string and is included in the character count.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "Ground control to Major Tom." | truncate: 20 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | truncate: 20 }}
```

### Custom ellipsis

`truncate` takes an optional second parameter that specifies the sequence of characters to be appended to the truncated string. By default this is an ellipsis (...), but you can specify a different sequence.

The length of the second parameter counts against the number of characters specified by the first parameter. For example, if you want to truncate a string to exactly 10 characters, and use a 3-character ellipsis, use **13** for the first parameter of `truncate`, since the ellipsis counts as 3 characters.

<p class="code-label">Input</p>
{% raw %}
``` liquid
{{ "Ground control to Major Tom." | truncate: 25, ", and so on" }}
```
{% endraw %}

<p class="code-label">Output</p>
``` text
{{ "Ground control to Major Tom." | truncate: 25, ", and so on" }}
```

### No ellipsis

You can truncate to the exact number of characters specified by the first parameter and show no trailing characters by passing a blank string as the second parameter:

<p class="code-label">Input</p>
{% raw %}
``` liquid
{{ "Ground control to Major Tom." | truncate: 20, "" }}
```
{% endraw %}

<p class="code-label">Output</p>
``` text
{{ "Ground control to Major Tom." | truncate: 20, "" }}
```
