---
title: replace_first
---

Replaces only the first occurrence of the first argument in a string with the second argument.

```liquid
{% raw %}
{% assign my_string = "Take my protein pills and put my helmet on" %}
{{ my_string | replace_first: "my", "your" }}
{% endraw %}
```

```text
{% assign my_string = "Take my protein pills and put my helmet on" %}
{{ my_string | replace_first: "my", "your" }}
```
