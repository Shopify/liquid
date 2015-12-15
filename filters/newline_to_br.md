---
title: newline_to_br
---

Replaces every newline (`\n`) with an HTML line break (`<br>`).

```liquid
{% raw %}
{% capture string_with_newlines %}
Hello
there
{% endcapture %}

{{ string_with_newlines | newline_to_br }}
{% endraw %}
```

```html
{% capture string_with_newlines %}
Hello
there
{% endcapture %}

{{ string_with_newlines | newline_to_br }}
```
