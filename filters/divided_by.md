---
title: divided_by
---

`divided_by` divides its input (left side) by its argument (right side). It uses `to_number`, which converts to a decimal value unless already a numeric.

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
