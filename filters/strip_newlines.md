---
title: strip_newlines
---

Removes any newline characters (line breaks) from a string.

```liquid
{% raw %}
{% capture string_with_newlines %}
Hello
there
{% endcapture %}

{{ string_with_newlines | strip_newlines }}
{% endraw %}
```

```html
{% capture string_with_newlines %}
Hello
there
{% endcapture %}

{{ string_with_newlines | strip_newlines }}
```

