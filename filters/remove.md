---
title: remove
---

`remove` removes every occurrence of of the passed-in substring from the input string.

```liquid
{% raw %}
{{ "I strained to see the train through the rain" | remove: "rain" }}
{% endraw %}
```

```text
{{ "I strained to see the train through the rain" | remove: "rain" }}
```
