---
title: ceil
---

`ceil` rounds the input up to the nearest whole number. The filter will attempt to cast any input to a number before it is applied.

```liquid
{% raw %}
{{ 1.2 | ceil }}
{% endraw %}
```

```text
2
```

```liquid
{% raw %}
{{ 2.0 | ceil }}
{% endraw %}
```

```text
2
```

```liquid
{% raw %}
{{ 183.357 | ceil }}
{% endraw %}
```

```text
184
```
