---
title: url_encode
category: aaa
description: Liquid filter that encodes URL-unsafe characters in a string.
---

Converts any URL-unsafe characters in a string into percent-encoded characters.

Note that `url_encode` will turn a space into a `+` sign instead of a percent-encoded character.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "john@liquid.com" | url_encode }}
{{ "Tetsuro Takara" | url_encode }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "john@liquid.com" | url_encode }}
{{ "Tetsuro Takara" | url_encode }}
```
