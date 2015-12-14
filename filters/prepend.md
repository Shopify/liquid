---
title: prepend
---

`prepend` adds a string to the beginning of the input string.

```liquid
{% raw %}
{{ "apples, oranges, and bananas" | prepend: "Some fruit: " }}
{% endraw %}
```

```text
{{ "apples, oranges, and bananas" | prepend: "Some fruit: " }}
```

You can also `prepend` variables:

```liquid
{% raw %}
{% assign url = "liquidmarkup.com" %}

{{ "/index.html" | prepend: url }}
{% endraw %}
```

```text
{% assign url = "liquidmarkup.com" %}

{{ "/index.html" | prepend: url }}
```
