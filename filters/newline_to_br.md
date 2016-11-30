---
title: newline_to_br
description: Liquid filter that converts newlines in an input string to HTML <br> tags.
---

Replaces every newline (`\n`) with an HTML line break (`<br>`).

<p class="code-label">Input</p>
```liquid
{% raw %}
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
