---
title: newline_to_br
description: Liquid filter that converts newlines in a string to HTML <br /> tags.
---

Inserts an HTML line break (`<br />`) in front of each newline (`\n`) in a string.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% capture string_with_newlines %}
Hello
there
{% endcapture %}

{{ string_with_newlines | newline_to_br }}
{% endraw %}
```

<p class="code-label">Output</p>
```html
{% capture string_with_newlines %}
Hello
there
{% endcapture %}

{{ string_with_newlines | newline_to_br }}
```
