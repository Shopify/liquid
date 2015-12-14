---
title: replace_first
---

`replace_first` replaces the first occurrence of the first passed-in string in the input string with the second passed-in string.

```liquid
{% raw %}
{{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
{% endraw %}
```

```text
{{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
```
