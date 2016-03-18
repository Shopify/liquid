---
title: truncate
---

`truncate` shortens a string  down to the number of characters passed as a parameter. If the number of characters specified is less than the length of the string, an ellipsis (...) is appended to the string and is included in the character count.

```liquid
{% raw %}
{{ "Ground control to Major Tom." | truncate: 20 }}
{% endraw %}
```

```text
{{ "Ground control to Major Tom." | truncate: 20 }}
```
