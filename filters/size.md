---
title: size
---

Returns the number of characters in a string or the number of items in an array. `size` can also be used with dot notation (for example, `{% raw %}{{ my_string.size }}{% endraw %}`). This allows you to use `size` inside  tags such as conditionals.

```liquid
{% raw %}
{{ "Ground control to Major Tom." | size }}
{% endraw %}
```

```text
{{ "Ground control to Major Tom." | size }}
```

```liquid
{% raw %}
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array | size }}
{% endraw %}
```

```text
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " %}

{{ my_array | size }}
```

Using dot notation:

```liquid
{% raw %}
{% if site.pages.size > 10 %}
  This is a big website!
{% endif %}
{% endraw %}
```
