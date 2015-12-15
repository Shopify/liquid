---
title: divided_by
---

Divides a number by its argument.

The result is rounded down to the nearest integer (that is, the [floor](/filters/floor)).

```liquid
{% raw %}
{{ 4 | divided_by: 2 }}
{% endraw %}
```

```text
{{ 4 | divided_by: 2 }}
```

```liquid
{% raw %}
{{ 16 | divided_by: 4 }}
{% endraw %}
```

```text
{{ 16 | divided_by: 4 }}
```

```liquid
{% raw %}
{{ 5 | divided_by: 3 }}
{% endraw %}
```

```text
{{ 5 | divided_by: 3 }}
```
