---
title: truncatewords
description: Liquid filter that truncates a string to the given number of words.
---

Shortens a string down to the number of words passed as the argument. If the specified number of words is less than the number of words in the string, an ellipsis (...) is appended to the string.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "Ground control to Major Tom." | truncatewords: 3 }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Ground control to Major Tom." | truncatewords: 3 }}
```

### Custom ellipsis

`truncatewords` takes an optional second parameter that specifies the sequence of characters to be appended to the truncated string. By default this is an ellipsis (...), but you can specify a different sequence.

<p class="code-label">Input</p>
{% raw %}
``` liquid
{{ "Ground control to Major Tom." | truncatewords: 3, "--" }}
```
{% endraw %}

<p class="code-label">Output</p>
``` text
{{ "Ground control to Major Tom." | truncatewords: 3, "--" }}
```

### No ellipsis

You can avoid showing trailing characters by passing a blank string as the second parameter:

<p class="code-label">Input</p>
{% raw %}
``` liquid
{{ "Ground control to Major Tom." | truncatewords: 3, "" }}
```
{% endraw %}

<p class="code-label">Output</p>
``` text
{{ "Ground control to Major Tom." | truncatewords: 3, "" }}
```
