---
title: remove_first
---

`remove` removes the first occurrence of of the passed-in substring from the input string.

```liquid
{% raw %}
{{ "I strained to see the train through the rain" | remove_first: "rain" }}
{% endraw %}
```

```text
{{ "I strained to see the train through the rain" | remove_first: "rain" }}
```
