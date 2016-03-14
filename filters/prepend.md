---
title: prepend
---

Adds the specified string to the beginning of another string.

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
