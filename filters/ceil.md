---
title: ceil
---

Rounds the input up to the nearest whole number. Liquid tries to convert the input to a number before the filter is applied.

```liquid
{% raw %}
{{ 1.2 | ceil }}
{% endraw %}
```

```text
{{ 1.2 | ceil }}
```

```liquid
{% raw %}
{{ 2.0 | ceil }}
{% endraw %}
```

```text
{{ 2.0 | ceil }}
```

```liquid
{% raw %}
{{ 183.357 | ceil }}
{% endraw %}
```

```text
{{ 183.357 | ceil }}
```

Here the input value is a string:

```liquid
{% raw %}
{{ "3.5" | ceil }}
{% endraw %}
```

```text
{{ "3.5" | ceil }}
```
