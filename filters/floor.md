---
title: floor
---

Rounds a number down to the nearest whole number. Liquid tries to convert the input to a number before the filter is applied.

```liquid
{% raw %}
{{ 1.2 | floor }}
{% endraw %}
```

```text
{{ 1.2 | floor }}
```

```liquid
{% raw %}
{{ 2.0 | floor }}
{% endraw %}
```

```text
{{ 2.0 | floor }}
```

```liquid
{% raw %}
{{ 183.357 | floor }}
{% endraw %}
```

```text
{{ 183.357 | floor }}
```

Here the input value is a string:

```liquid
{% raw %}
{{ "3.5" | floor }}
{% endraw %}
```

```text
{{ "3.5" | floor }}
```
